import Foundation
import Observation

struct Conversation: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String = "新しい会話"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var modelName: String = ""
    var messages: [ChatMessage] = []

    var preview: String {
        let last = messages.last(where: { !$0.content.isEmpty })?.content ?? ""
        return last.replacingOccurrences(of: "\n", with: " ")
    }
}

/// 会話の保存先: Application Support/Conversations/<id>.json(iCloudバックアップ対象)
@Observable
@MainActor
final class ConversationStore {
    static let shared = ConversationStore()

    /// 新しい順
    private(set) var conversations: [Conversation] = []

    private init() { load() }

    private static var dir: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Conversations", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func file(_ id: UUID) -> URL {
        dir.appendingPathComponent(id.uuidString + ".json")
    }

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func load() {
        let urls = (try? FileManager.default.contentsOfDirectory(at: Self.dir, includingPropertiesForKeys: nil)) ?? []
        conversations = urls
            .filter { $0.pathExtension == "json" }
            .compactMap { try? Self.decoder.decode(Conversation.self, from: Data(contentsOf: $0)) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func conversation(_ id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    func save(_ conv: Conversation) {
        guard !conv.messages.isEmpty else { return }
        if let data = try? Self.encoder.encode(conv) {
            try? data.write(to: Self.file(conv.id), options: .atomic)
        }
        conversations.removeAll { $0.id == conv.id }
        conversations.insert(conv, at: 0)
    }

    func delete(_ id: UUID) {
        try? FileManager.default.removeItem(at: Self.file(id))
        conversations.removeAll { $0.id == id }
    }

    func rename(_ id: UUID, to title: String) {
        guard var c = conversation(id) else { return }
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        c.title = t.isEmpty ? c.title : t
        if let data = try? Self.encoder.encode(c) {
            try? data.write(to: Self.file(c.id), options: .atomic)
        }
        if let i = conversations.firstIndex(where: { $0.id == id }) { conversations[i] = c }
    }
}
