import SwiftUI

struct ChatView: View {
    @Bindable var vm: ChatViewModel
    @State private var showHistory = false
    @State private var selecting: SelectableText?

    var body: some View {
        NavigationStack {
            messageList
                // 状態表示と入力欄は会話の上に浮かぶガラス。会話はその下に潜り込んでスクロールする
                .safeAreaInset(edge: .top, spacing: 0) { statusBanner }
                .safeAreaInset(edge: .bottom, spacing: 0) { ChatInputBar(vm: vm) }
                .navigationTitle(currentTitle)
                .sheet(item: $selecting) { item in
                    SelectTextSheet(text: item.text)
                }
                .sheet(isPresented: $showHistory) {
                    NavigationStack {
                        HistoryView(vm: vm) { showHistory = false }
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("閉じる") { showHistory = false }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { showHistory = true } label: { Image(systemName: "clock.arrow.circlepath") }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { vm.clear() } label: { Image(systemName: "square.and.pencil") }
                            .disabled(vm.messages.isEmpty)
                    }
                }
        }
    }

    private var currentTitle: String {
        guard let id = vm.conversationID, let c = ConversationStore.shared.conversation(id) else { return "よろず" }
        return c.title
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch vm.state {
        case .noModel:
            banner(Label("モデルが無いだ。「モデル」タブからダウンロードしてけろ", systemImage: "tray"), tint: .orange)
        case .loading(let name):
            banner(HStack(spacing: 8) {
                ProgressView()
                Text("読み込み中: \(name)")
            }, tint: .blue)
        case .failed(let msg):
            banner(Label(msg, systemImage: "exclamationmark.triangle"), tint: .red)
        case .unloaded:
            if let note = vm.releaseNote {
                banner(Label(note, systemImage: "memorychip"), tint: .orange)
            } else {
                EmptyView()
            }
        case .ready:
            EmptyView()
        }
    }

    private func banner(_ content: some View, tint: Color) -> some View {
        content
            .font(.footnote)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .yorozuGlass(in: Capsule(), tint: tint.opacity(0.25))
            .padding(.horizontal)
            .padding(.top, 4)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if vm.messages.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(.tint)
                            Text("なんでも聞いてけろ。\nこのiPhoneの中だけで動いてて、会話は外に出ないだ。")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                    }
                    ForEach(vm.messages) { msg in
                        let isLast = msg.id == vm.messages.last?.id
                        MessageBubble(
                            message: msg,
                            showActions: msg.role == .assistant && !(isLast && vm.isGenerating),
                            canRegenerate: isLast && vm.canRegenerate,
                            onRegenerate: { vm.regenerate() },
                            onSelectText: { selecting = SelectableText(text: msg.content) }
                        )
                        .equatable()
                        .id(msg.id)
                    }
                    if let err = vm.errorText {
                        Text(err).font(.footnote).foregroundStyle(.red)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.last?.content) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
            .onChange(of: vm.messages.count) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
}

/// 入力欄。打っている文字はここだけで持つので、1文字ごとに会話リスト全体が描き直されない。
struct ChatInputBar: View {
    var vm: ChatViewModel
    @State private var input = ""
    @FocusState private var focused: Bool

    private var canSend: Bool {
        vm.canAcceptInput && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("メッセージ", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .focused($focused)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .yorozuGlass(in: RoundedRectangle(cornerRadius: 22, style: .continuous))

            Group {
                if vm.isGenerating {
                    Button { vm.stop() } label: {
                        Image(systemName: "stop.fill").frame(width: 22, height: 22)
                    }
                    .glassButtonStyle()
                } else {
                    Button {
                        vm.send(input)
                        input = ""
                    } label: {
                        Image(systemName: "arrow.up").fontWeight(.semibold).frame(width: 22, height: 22)
                    }
                    .glassButtonStyle(prominent: true)
                    .disabled(!canSend)
                }
            }
            .buttonBorderShape(.circle)
            .controlSize(.large)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .padding(.top, 4)
    }
}

struct SelectableText: Identifiable {
    let id = UUID()
    let text: String
}

struct MessageBubble: View, Equatable {
    let message: ChatMessage
    var showActions = false
    var canRegenerate = false
    var onRegenerate: () -> Void = {}
    var onSelectText: () -> Void = {}

    @State private var copied = false

    // 中身が変わった時だけ描き直す(クロージャは比較しない)
    static func == (a: MessageBubble, b: MessageBubble) -> Bool {
        a.message == b.message && a.showActions == b.showActions && a.canRegenerate == b.canRegenerate
    }

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                bubble
                    .contextMenu { menu }
                if showActions { actionRow }
            }
            if !isUser { Spacer(minLength: 24) }
        }
    }

    private var bubble: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(isUser ? Color.white : Color.primary)
            .background(
                isUser ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(Color(.secondarySystemBackground)),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if message.content.isEmpty {
            Text("…")
        } else if !isUser {
            // AIの返答はマークダウンとして表示(見出し・箇条書き・コード・表など)
            MarkdownView(source: message.content)
        } else {
            Text(message.content)
        }
    }

    @ViewBuilder
    private var menu: some View {
        Button { copy() } label: { Label("コピー", systemImage: "doc.on.doc") }
        Button { onSelectText() } label: { Label("テキストを選択", systemImage: "selection.pin.in.out") }
        if canRegenerate {
            Button { onRegenerate() } label: { Label("再生成", systemImage: "arrow.clockwise") }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            Button { copy() } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
            }
            Button { onSelectText() } label: {
                Image(systemName: "selection.pin.in.out")
            }
            if canRegenerate {
                Button { onRegenerate() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .buttonStyle(.borderless)
        .padding(.leading, 8)
    }

    private func copy() {
        UIPasteboard.general.string = message.content
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        copied = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            copied = false
        }
    }
}

/// 好きな範囲を選んでコピーできる画面(iOS 標準の文字選択)
struct SelectTextSheet: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SelectableTextView(text: text)
                .padding(.horizontal, 12)
                .navigationTitle("テキストを選択")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("全部コピー") {
                            UIPasteboard.general.string = text
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            dismiss()
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SelectableTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let v = UITextView()
        v.isEditable = false
        v.isSelectable = true
        v.backgroundColor = .clear
        v.font = .preferredFont(forTextStyle: .body)
        v.adjustsFontForContentSizeCategory = true
        v.textContainerInset = UIEdgeInsets(top: 12, left: 4, bottom: 24, right: 4)
        v.dataDetectorTypes = [.link]
        v.text = text
        return v
    }

    func updateUIView(_ v: UITextView, context: Context) {
        if v.text != text { v.text = text }
    }
}
