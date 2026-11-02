import SwiftUI
import Observation

enum Prefs {
    static let systemPrompt = "systemPrompt"
    static let temperature = "temperature"
    static let maxTokens = "maxTokens"
    static let contextSize = "contextSize"

    /// 6GB機(14 Pro など)はメモリに余裕が無いので短めにする
    static let defaultContextSize: Int =
        ProcessInfo.processInfo.physicalMemory <= 6_500_000_000 ? 2048 : 4096

    static let defaultSystemPrompt =
        "あなたは「よろず」という、ユーザーのiPhoneの中だけで動くAIアシスタントです。日本語で、自然で率直に答えてください。"
}

struct ChatMessage: Identifiable, Equatable {
    enum Role: String { case user, assistant }
    let id = UUID()
    let role: Role
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

    var state: State = .noModel
    var messages: [ChatMessage] = []
    var isGenerating = false
    var errorText: String?

    private let engine = LlamaEngine()
    private var generationTask: Task<Void, Never>?

    var isReady: Bool { if case .ready = state { return true } else { return false } }

    func loadModel(at url: URL?, contextSize: Int) async {
        stop()
        guard let url else {
            await engine.unload()
            state = .noModel
            return
        }
        state = .loading(url.lastPathComponent)
        do {
            try await engine.load(path: url.path, contextSize: contextSize)
            state = .ready(url.lastPathComponent)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, isReady, !isGenerating else { return }

        let ud = UserDefaults.standard
        let system = ud.string(forKey: Prefs.systemPrompt) ?? Prefs.defaultSystemPrompt
        let temp = ud.object(forKey: Prefs.temperature) as? Double ?? 0.7
        let maxTokens = ud.object(forKey: Prefs.maxTokens) as? Int ?? 1024

        messages.append(ChatMessage(role: .user, content: trimmed))
        var turns: [ChatTurn] = []
        if !system.isEmpty { turns.append(ChatTurn(role: "system", content: system)) }
        turns += messages.map { ChatTurn(role: $0.role.rawValue, content: $0.content) }

        messages.append(ChatMessage(role: .assistant, content: ""))
        let index = messages.count - 1
        isGenerating = true
        errorText = nil
        UIApplication.shared.isIdleTimerDisabled = true

        let params = GenerationParams(temperature: Float(temp), maxTokens: maxTokens)
        generationTask = Task { [engine] in
            do {
                for try await piece in engine.generate(turns: turns, params: params) {
                    guard index < messages.count else { break }
                    messages[index].content += piece
                }
            } catch {
                errorText = error.localizedDescription
            }
            isGenerating = false
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func stop() {
        generationTask?.cancel()
    }

    func clear() {
        stop()
        messages.removeAll()
        errorText = nil
    }
}
