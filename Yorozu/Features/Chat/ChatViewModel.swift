import SwiftUI
import Observation

enum Prefs {
    static let systemPrompt = "systemPrompt"
    static let temperature = "temperature"
    static let maxTokens = "maxTokens"
    static let contextSize = "contextSize"
    static let islandEnabled = "islandEnabled"

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

    func loadModel(at url: URL?, contextSize: Int) async {
        stop()
        guard let url else {
            await engine.unload()
            setState(.noModel)
            return
        }
        setState(.loading(url.lastPathComponent))
        do {
            try await engine.load(path: url.path, contextSize: contextSize)
            setState(.ready(url.lastPathComponent))
        } catch {
            setState(.failed(error.localizedDescription))
        }
    }

    private func setState(_ s: State) {
        state = s
        LiveActivityManager.shared.update(force: true) {
            switch s {
            case .noModel: $0.engine = .noModel; $0.modelName = ""
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

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, isReady, !isGenerating else { return }

        let ud = UserDefaults.standard
        let system = ud.string(forKey: Prefs.systemPrompt) ?? Prefs.defaultSystemPrompt
        let temp = ud.object(forKey: Prefs.temperature) as? Double ?? 0.7
        let maxTokens = ud.object(forKey: Prefs.maxTokens) as? Int ?? 1024

        messages.append(ChatMessage(role: .user, content: trimmed))
        if conversationID == nil { conversationID = UUID() }
        let convID = conversationID
        persist()
        var turns: [ChatTurn] = []
        if !system.isEmpty { turns.append(ChatTurn(role: "system", content: system)) }
        turns += messages.map { ChatTurn(role: $0.role.rawValue, content: $0.content) }

        messages.append(ChatMessage(role: .assistant, content: ""))
        let index = messages.count - 1
        isGenerating = true
        errorText = nil
        UIApplication.shared.isIdleTimerDisabled = true
        LiveActivityManager.shared.update(force: true) {
            $0.engine = .generating
            $0.snippet = Self.tail(trimmed)
        }

        let params = GenerationParams(temperature: Float(temp), maxTokens: maxTokens)
        generationTask = Task { [engine] in
            do {
                for try await piece in engine.generate(turns: turns, params: params) {
                    // 生成中に別の会話を開いた時に混ざらないように
                    guard conversationID == convID, index < messages.count else { break }
                    messages[index].content += piece
                    let snippet = Self.tail(messages[index].content)
                    LiveActivityManager.shared.update { $0.snippet = snippet }
                }
            } catch {
                errorText = error.localizedDescription
            }
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
        if case .ready(let name) = state { conv.modelName = name }
        store.save(conv)
    }
}
