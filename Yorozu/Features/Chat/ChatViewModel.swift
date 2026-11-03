import SwiftUI
import Observation

enum Prefs {
    static let systemPrompt = "systemPrompt"
    static let temperature = "temperature"
    static let maxTokens = "maxTokens"
    static let contextSize = "contextSize"
    static let islandEnabled = "islandEnabled"
    static let keepModelInBackground = "keepModelInBackground"

    /// 6GB機(14 Pro など)はメモリに余裕が無いので短めにする
    static let defaultContextSize: Int =
        ProcessInfo.processInfo.physicalMemory <= 6_500_000_000 ? 2048 : 4096

    static let defaultSystemPrompt =
        "あなたは「よろず」という、ユーザーのiPhoneの中だけで動くAIアシスタントです。日本語で、自然で率直に答えてください。"
}

struct ChatMessage: Identifiable, Equatable, Hashable, Codable {
    enum Role: String, Codable { case user, assistant }
    var id: UUID = UUID()
    var role: Role
    var content: String
}

@Observable
@MainActor
final class ChatViewModel {
    enum State: Equatable {
        case noModel
        /// 選ばれてるけどメモリには載せてない(チャットを開くか話しかけると読み込む)
        case unloaded(String)
        case loading(String)
        case ready(String)
        case failed(String)
    }

    private(set) var state: State = .noModel
    var messages: [ChatMessage] = []
    /// 今開いている会話(まだ1通も送ってなければ nil)
    private(set) var conversationID: UUID?
    var isGenerating = false
    var errorText: String?

    private let engine = LlamaEngine()
    private var generationTask: Task<Void, Never>?

    var isReady: Bool { if case .ready = state { return true } else { return false } }

    // MARK: - モデルの読み込み/解放
    // 4Bモデルは約3GBを握るので、6GB機では載せっぱなしだと端末全体が重くなる。
    // そこで「チャットを使う時だけ載せる/裏に回ったら外す」にしている。

    private var desiredURL: URL?
    private var desiredContext = 0
    private var loadedKey: String?
    private var loadTask: Task<Void, Never>?
    /// メモリ不足で外した時の一言
    var releaseNote: String?

    private func key(_ url: URL, _ ctx: Int) -> String { "\(url.path)|\(ctx)" }

    /// 使うモデルを決める(まだ読み込まない)。違うモデルが載っていたら外す。
    func configure(url: URL?, contextSize: Int) async {
        desiredURL = url
        desiredContext = contextSize
        guard let url else {
            await release()
            setState(.noModel)
            return
        }
        if loadedKey == key(url, contextSize) { return }
        if loadedKey != nil || loadTask != nil { await release() }
        setState(.unloaded(url.lastPathComponent))
    }

    /// チャットを開いた時/話しかけた時に呼ぶ。載ってなければ載せる。
    func ensureLoaded() async {
        guard let url = desiredURL else { return }
        let k = key(url, desiredContext)
        if loadedKey == k { return }
        if let t = loadTask { await t.value; return }
        let ctx = desiredContext
        let task = Task { [engine] in
            setState(.loading(url.lastPathComponent))
            do {
                try await engine.load(path: url.path, contextSize: ctx)
                loadedKey = k
                releaseNote = nil
                setState(.ready(url.lastPathComponent))
            } catch {
                loadedKey = nil
                setState(.failed(error.localizedDescription))
            }
        }
        loadTask = task
        await task.value
        loadTask = nil
        runPendingAction()
    }

    /// メモリから外す(生成中なら止めてから)
    func release(note: String? = nil) async {
        stop()
        if let t = loadTask { await t.value }
        guard loadedKey != nil else { return }
        await engine.unload()
        loadedKey = nil
        if let note { releaseNote = note }
        if let url = desiredURL { setState(.unloaded(url.lastPathComponent)) }
    }

    /// 送信ボタンを押せるか(載ってなくても、押せば読み込んでから送る)
    var canAcceptInput: Bool {
        switch state {
        case .ready, .unloaded: return true
        default: return false
        }
    }

    private func setState(_ s: State) {
        state = s
        LiveActivityManager.shared.update(force: true) {
            switch s {
            case .noModel: $0.engine = .noModel; $0.modelName = ""
            case .unloaded(let n): $0.engine = .ready; $0.modelName = n
            case .loading(let n): $0.engine = .loading; $0.modelName = n
            case .ready(let n): $0.engine = .ready; $0.modelName = n
            case .failed(let m): $0.engine = .error; $0.snippet = m
            }
        }
    }

    private static func tail(_ text: String, _ n: Int = 80) -> String {
        let flat = text.replacingOccurrences(of: "\n", with: " ")
        return flat.count > n ? "…" + String(flat.suffix(n)) : flat
    }

    private enum PendingAction { case send(String), regenerate }
    private var pendingAction: PendingAction?

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAcceptInput, !isGenerating else { return }
        if !isReady {
            // まだ載ってないので、読み込んでから送る
            pendingAction = .send(trimmed)
            Task { await ensureLoaded() }
            return
        }
        messages.append(ChatMessage(role: .user, content: trimmed))
        if conversationID == nil { conversationID = UUID() }
        persist()
        generateReply()
    }

    /// 最後の返答を作り直せるか
    var canRegenerate: Bool {
        !isGenerating && canAcceptInput && messages.last?.role == .assistant
            && messages.dropLast().last?.role == .user
    }

    /// 最後の返答を消して、同じ質問でもう一度答えさせる
    func regenerate() {
        guard canRegenerate else { return }
        if !isReady {
            pendingAction = .regenerate
            Task { await ensureLoaded() }
            return
        }
        messages.removeLast()
        generateReply()
    }

    private func runPendingAction() {
        guard isReady, let action = pendingAction else { return }
        pendingAction = nil
        switch action {
        case .send(let text): send(text)
        case .regenerate: regenerate()
        }
    }

    /// messages の最後(ユーザーの発言)に対する返答を生成する
    private func generateReply() {
        let ud = UserDefaults.standard
        let system = ud.string(forKey: Prefs.systemPrompt) ?? Prefs.defaultSystemPrompt
        let temp = ud.object(forKey: Prefs.temperature) as? Double ?? 0.7
        let maxTokens = ud.object(forKey: Prefs.maxTokens) as? Int ?? 1024

        let convID = conversationID
        var turns: [ChatTurn] = []
        if !system.isEmpty { turns.append(ChatTurn(role: "system", content: system)) }
        turns += messages.map { ChatTurn(role: $0.role.rawValue, content: $0.content) }
        let question = messages.last?.content ?? ""

        messages.append(ChatMessage(role: .assistant, content: ""))
        let index = messages.count - 1
        isGenerating = true
        errorText = nil
        UIApplication.shared.isIdleTimerDisabled = true
        LiveActivityManager.shared.update(force: true) {
            $0.engine = .generating
            $0.snippet = Self.tail(question)
        }

        let params = GenerationParams(temperature: Float(temp), maxTokens: maxTokens)
        generationTask = Task { [engine] in
            // 1トークンごとに画面を更新すると重いので、0.08秒ぶんまとめて流し込む
            var buffer = ""
            var lastFlush = CFAbsoluteTimeGetCurrent()
            do {
                for try await piece in engine.generate(turns: turns, params: params) {
                    guard conversationID == convID else { break }
                    buffer += piece
                    let now = CFAbsoluteTimeGetCurrent()
                    if now - lastFlush >= 0.08 {
                        appendChunk(buffer, at: index, convID: convID)
                        buffer = ""
                        lastFlush = now
                    }
                }
            } catch {
                errorText = error.localizedDescription
            }
            appendChunk(buffer, at: index, convID: convID)
            isGenerating = false
            UIApplication.shared.isIdleTimerDisabled = false
            if conversationID == convID { persist() }
            let final = index < messages.count ? Self.tail(messages[index].content) : ""
            let ready = isReady
            LiveActivityManager.shared.update(force: true) {
                $0.engine = ready ? .ready : $0.engine
                $0.snippet = final
            }
        }
    }

    private func appendChunk(_ chunk: String, at index: Int, convID: UUID?) {
        // 生成中に別の会話を開いた時に混ざらないように
        guard !chunk.isEmpty, conversationID == convID, index < messages.count else { return }
        messages[index].content += chunk
        let snippet = Self.tail(messages[index].content)
        LiveActivityManager.shared.update { $0.snippet = snippet }
    }

    func stop() {
        generationTask?.cancel()
    }

    /// 新しい会話を始める(今の会話は保存済み)
    func clear() {
        stop()
        persist()
        messages.removeAll()
        conversationID = nil
        errorText = nil
    }

    func open(_ conv: Conversation) {
        guard conv.id != conversationID else { return }
        stop()
        persist()
        messages = conv.messages
        conversationID = conv.id
        errorText = nil
    }

    /// 削除された会話を開いていたら閉じる
    func forget(_ id: UUID) {
        guard id == conversationID else { return }
        stop()
        messages.removeAll()
        conversationID = nil
    }

    private func persist() {
        guard let id = conversationID, !messages.isEmpty else { return }
        let store = ConversationStore.shared
        var conv = store.conversation(id) ?? Conversation(id: id)
        if conv.messages.isEmpty || conv.title == "新しい会話",
           let first = messages.first(where: { $0.role == .user })?.content {
            let flat = first.replacingOccurrences(of: "\n", with: " ")
            conv.title = flat.count > 30 ? String(flat.prefix(30)) + "…" : flat
        }
        conv.messages = messages
        conv.updatedAt = Date()
        switch state {
        case .ready(let name), .unloaded(let name): conv.modelName = name
        default: break
        }
        store.save(conv)
    }
}
