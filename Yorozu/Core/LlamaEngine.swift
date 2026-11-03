import Foundation
import llama

struct ChatTurn: Sendable {
    var role: String      // "system" | "user" | "assistant"
    var content: String
}

struct GenerationParams: Sendable {
    var temperature: Float = 0.7
    var topP: Float = 0.9
    var topK: Int32 = 40
    var maxTokens: Int = 1024
}

/// llama.cpp の C API を包む薄いラッパー。
/// モデルのロード/アンロードと、ストリーミング生成だけを担当する。
private let llamaBackendInit: Void = { llama_backend_init() }()

actor LlamaEngine {
    enum EngineError: LocalizedError {
        case modelLoadFailed
        case contextFailed
        case notLoaded
        case tokenizeFailed
        case templateFailed
        case promptTooLong
        case decodeFailed(Int32)

        var errorDescription: String? {
            switch self {
            case .modelLoadFailed: return "モデルを読み込めなかっただ(メモリ不足かファイルが壊れてるかも)"
            case .contextFailed: return "コンテキストの確保に失敗しただ(コンテキスト長を小さくしてみてけろ)"
            case .notLoaded: return "モデルがまだ読み込まれてないだ"
            case .tokenizeFailed: return "トークン化に失敗しただ"
            case .templateFailed: return "チャットテンプレートの適用に失敗しただ"
            case .promptTooLong: return "入力が長すぎて、コンテキストに収まらないだ"
            case .decodeFailed(let rc): return "推論に失敗しただ (code \(rc))"
            }
        }
    }

    private var model: OpaquePointer?
    private var context: OpaquePointer?
    private var vocab: OpaquePointer?
    private var contextSize: Int = 0
    /// いま KV キャッシュに入っているトークン列(次の生成で共通部分を使い回す)
    private var cachedTokens: [llama_token] = []
    /// KV キャッシュを 8bit に圧縮できたか
    private(set) var kvQuantized = false

    /// 一度に処理するトークン数。小さいほど作業用メモリが減る(読み込みは少し遅くなる)
    private let batchSize = 256

    deinit {
        if let c = context { llama_free(c) }
        if let m = model { llama_model_free(m) }
    }

    // MARK: - Load / Unload

    func load(path: String, contextSize: Int) throws {
        unload()
        _ = llamaBackendInit

        var mp = llama_model_default_params()
        #if targetEnvironment(simulator)
        mp.n_gpu_layers = 0
        #else
        mp.n_gpu_layers = 999
        #endif

        guard let m = llama_model_load_from_file(path, mp) else {
            throw EngineError.modelLoadFailed
        }

        func contextParams(quantizeKV: Bool) -> llama_context_params {
            var cp = llama_context_default_params()
            cp.n_ctx = UInt32(contextSize)
            cp.n_batch = UInt32(batchSize)
            cp.n_ubatch = UInt32(batchSize)
            let threads = Int32(max(2, min(6, ProcessInfo.processInfo.activeProcessorCount - 2)))
            cp.n_threads = threads
            cp.n_threads_batch = threads
            if quantizeKV {
                // 会話の記憶(KVキャッシュ)を 8bit にしてメモリを約半分にする
                cp.type_k = GGML_TYPE_Q8_0
                cp.type_v = GGML_TYPE_Q8_0
            }
            return cp
        }

        // 8bit KV が使えない環境(Flash Attention 非対応など)なら普通の設定でやり直す
        var quantized = true
        var c = llama_init_from_model(m, contextParams(quantizeKV: true))
        if c == nil {
            quantized = false
            c = llama_init_from_model(m, contextParams(quantizeKV: false))
        }
        guard let c else {
            llama_model_free(m)
            throw EngineError.contextFailed
        }

        model = m
        context = c
        vocab = llama_model_get_vocab(m)
        self.contextSize = contextSize
        kvQuantized = quantized
        cachedTokens = []
    }

    func unload() {
        if let c = context { llama_free(c) }
        if let m = model { llama_model_free(m) }
        context = nil
        model = nil
        vocab = nil
        contextSize = 0
        cachedTokens = []
    }

    // MARK: - Generate

    /// 生成結果を文字列の断片として流す。Task をキャンセルすると止まる。
    nonisolated func generate(turns: [ChatTurn], params: GenerationParams) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                await self.run(turns: turns, params: params, continuation: continuation)
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func run(
        turns: [ChatTurn],
        params: GenerationParams,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) {
        do {
            guard let ctx = context, vocab != nil else { throw EngineError.notLoaded }

            let maxNew = max(16, min(params.maxTokens, contextSize / 2))
            let budget = contextSize - maxNew

            // 入りきらなければ古いやり取りから捨てる
            var turns = turns
            var tokens = try tokenize(try buildPrompt(turns))
            while tokens.count > budget,
                  let idx = turns.firstIndex(where: { $0.role != "system" }),
                  turns.count > 1 {
                turns.remove(at: idx)
                if idx < turns.count, turns[idx].role == "assistant" { turns.remove(at: idx) }
                tokens = try tokenize(try buildPrompt(turns))
            }
            guard tokens.count <= budget else { throw EngineError.promptTooLong }

            let chain = llama_sampler_chain_init(llama_sampler_chain_default_params())!
            defer { llama_sampler_free(chain) }
            llama_sampler_chain_add(chain, llama_sampler_init_top_k(params.topK))
            llama_sampler_chain_add(chain, llama_sampler_init_top_p(params.topP, 1))
            llama_sampler_chain_add(chain, llama_sampler_init_temp(params.temperature))
            llama_sampler_chain_add(chain, llama_sampler_init_dist(UInt32.random(in: 0..<UInt32.max)))

            // 前回の会話と先頭が同じ部分は KV キャッシュを使い回して、増えた分だけ読む
            // (毎回全部読み直すより、長い会話ほど返答が速く始まる)
            let mem = llama_get_memory(ctx)
            var reuse = 0
            let limit = min(cachedTokens.count, tokens.count - 1)  // 最低1トークンは読んで続きを出させる
            while reuse < limit, cachedTokens[reuse] == tokens[reuse] { reuse += 1 }
            if reuse > 0, llama_memory_seq_rm(mem, 0, Int32(reuse), -1) {
                cachedTokens.removeSubrange(reuse...)
            } else {
                llama_memory_clear(mem, true)
                cachedTokens = []
                reuse = 0
            }

            try decodePrompt(Array(tokens[reuse...]))

            var pending: [UInt8] = []
            var produced = 0
            while produced < maxNew {
                if Task.isCancelled { break }

                let tok = llama_sampler_sample(chain, ctx, -1)
                if llama_vocab_is_eog(vocab, tok) { break }

                pending.append(contentsOf: pieceBytes(for: tok))
                // 日本語はトークンがUTF-8の途中で切れることが多いので、完結してから流す
                if !pending.isEmpty {
                    if let s = String(bytes: pending, encoding: .utf8) {
                        continuation.yield(s)
                        pending.removeAll(keepingCapacity: true)
                    } else if pending.count >= 8 {
                        continuation.yield(String(decoding: pending, as: UTF8.self))
                        pending.removeAll(keepingCapacity: true)
                    }
                }
                produced += 1

                var next = tok
                let rc = llama_decode(ctx, llama_batch_get_one(&next, 1))
                if rc != 0 { throw EngineError.decodeFailed(rc) }
                cachedTokens.append(tok)
            }
            continuation.finish()
        } catch {
            // 途中で失敗したら KV キャッシュの中身が当てにならないので捨てる
            if let ctx = context { llama_memory_clear(llama_get_memory(ctx), true) }
            cachedTokens = []
            continuation.finish(throwing: error)
        }
    }

    // MARK: - Helpers

    private func decodePrompt(_ tokens: [llama_token]) throws {
        guard let ctx = context else { throw EngineError.notLoaded }
        var tokens = tokens
        var pos = 0
        while pos < tokens.count {
            if Task.isCancelled { return }
            let n = min(batchSize, tokens.count - pos)
            let rc = tokens.withUnsafeMutableBufferPointer { bp -> Int32 in
                let batch = llama_batch_get_one(bp.baseAddress! + pos, Int32(n))
                return llama_decode(ctx, batch)
            }
            if rc != 0 { throw EngineError.decodeFailed(rc) }
            cachedTokens.append(contentsOf: tokens[pos..<(pos + n)])
            pos += n
        }
    }

    private func tokenize(_ text: String) throws -> [llama_token] {
        guard vocab != nil else { throw EngineError.notLoaded }
        let utf8Count = text.utf8.count
        var tokens = [llama_token](repeating: 0, count: utf8Count + 16)
        var n = llama_tokenize(vocab, text, Int32(utf8Count), &tokens, Int32(tokens.count), false, true)
        if n < 0 {
            tokens = [llama_token](repeating: 0, count: Int(-n))
            n = llama_tokenize(vocab, text, Int32(utf8Count), &tokens, Int32(tokens.count), false, true)
        }
        guard n >= 0 else { throw EngineError.tokenizeFailed }
        return Array(tokens.prefix(Int(n)))
    }

    private func pieceBytes(for token: llama_token) -> [UInt8] {
        var buf = [CChar](repeating: 0, count: 64)
        var n = llama_token_to_piece(vocab, token, &buf, Int32(buf.count), 0, true)
        if n < 0 {
            buf = [CChar](repeating: 0, count: Int(-n))
            n = llama_token_to_piece(vocab, token, &buf, Int32(buf.count), 0, true)
        }
        guard n > 0 else { return [] }
        return buf.prefix(Int(n)).map { UInt8(bitPattern: $0) }
    }

    /// モデル内蔵のチャットテンプレートで整形する。未対応なら ChatML にフォールバック。
    private func buildPrompt(_ turns: [ChatTurn]) throws -> String {
        guard let model else { throw EngineError.notLoaded }

        let owned: [(UnsafeMutablePointer<CChar>, UnsafeMutablePointer<CChar>)] = turns.map {
            (strdup($0.role)!, strdup($0.content)!)
        }
        defer { owned.forEach { free($0.0); free($0.1) } }
        var msgs = owned.map { llama_chat_message(role: UnsafePointer($0.0), content: UnsafePointer($0.1)) }

        if let tmpl = llama_model_chat_template(model, nil),
           let s = applyTemplate(tmpl, &msgs, turns) {
            return s
        }
        let chatml = strdup("chatml")!
        defer { free(chatml) }
        if let s = applyTemplate(UnsafePointer(chatml), &msgs, turns) { return s }
        throw EngineError.templateFailed
    }

    private func applyTemplate(
        _ tmpl: UnsafePointer<CChar>,
        _ msgs: inout [llama_chat_message],
        _ turns: [ChatTurn]
    ) -> String? {
        var cap = max(4096, turns.reduce(0) { $0 + $1.content.utf8.count } * 2 + 1024)
        var buf = [CChar](repeating: 0, count: cap)
        var n = llama_chat_apply_template(tmpl, msgs, msgs.count, true, &buf, Int32(cap))
        if n > Int32(cap) {
            cap = Int(n) + 1
            buf = [CChar](repeating: 0, count: cap)
            n = llama_chat_apply_template(tmpl, msgs, msgs.count, true, &buf, Int32(cap))
        }
        guard n >= 0 else { return nil }
        return String(decoding: buf.prefix(Int(n)).map { UInt8(bitPattern: $0) }, as: UTF8.self)
    }
}
