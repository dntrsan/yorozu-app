import SwiftUI

/// 過去の会話一覧。タップで開く、スワイプで削除/名前変更。
struct HistoryView: View {
    var vm: ChatViewModel
    var onOpen: () -> Void

    private let store = ConversationStore.shared
    @State private var query = ""
    @State private var renaming: Conversation?
    @State private var newTitle = ""

    private var filtered: [Conversation] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return store.conversations }
        return store.conversations.filter { c in
            c.title.localizedCaseInsensitiveContains(q)
                || c.messages.contains { $0.content.localizedCaseInsensitiveContains(q) }
        }
    }

    var body: some View {
        List {
            if store.conversations.isEmpty {
                ContentUnavailableView("まだ会話が無いだ", systemImage: "bubble.left.and.bubble.right",
                                       description: Text("チャットで話すと、ここに残るだ"))
            }
            ForEach(filtered) { c in
                Button {
                    vm.open(c)
                    onOpen()
                } label: {
                    ConversationRow(conversation: c, isCurrent: c.id == vm.conversationID)
                }
                .tint(.primary)
                .swipeActions {
                    Button("削除", role: .destructive) {
                        vm.forget(c.id)
                        store.delete(c.id)
                    }
                    Button("名前") {
                        newTitle = c.title
                        renaming = c
                    }
                    .tint(.orange)
                }
            }
        }
        .searchable(text: $query, prompt: "会話を検索")
        .navigationTitle("会話履歴")
        .alert("名前を変える", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("タイトル", text: $newTitle)
            Button("保存") {
                if let r = renaming { store.rename(r.id, to: newTitle) }
                renaming = nil
            }
            Button("やめる", role: .cancel) { renaming = nil }
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    var isCurrent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                if isCurrent {
                    Text("表示中").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2), in: Capsule())
                }
                Spacer()
                Text(conversation.updatedAt, format: .relative(presentation: .named))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Text(conversation.preview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
        }
        .padding(.vertical, 2)
    }
}
