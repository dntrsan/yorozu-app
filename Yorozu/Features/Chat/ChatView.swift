import SwiftUI

struct ChatView: View {
    @Bindable var vm: ChatViewModel
    @State private var input = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            messageList
                // 状態表示と入力欄は会話の上に浮かぶガラス。会話はその下に潜り込んでスクロールする
                .safeAreaInset(edge: .top, spacing: 0) { statusBanner }
                .safeAreaInset(edge: .bottom, spacing: 0) { inputBar }
                .navigationTitle("よろず")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { vm.clear() } label: { Image(systemName: "square.and.pencil") }
                            .disabled(vm.messages.isEmpty)
                    }
                }
        }
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
                        MessageBubble(message: msg).id(msg.id)
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

    private var canSend: Bool {
        vm.isReady && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("メッセージ", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .focused($focused)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .yorozuGlass(in: RoundedRectangle(cornerRadius: 22, style: .continuous), interactive: true)

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

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.content.isEmpty ? "…" : message.content)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(message.role == .user ? Color.white : Color.primary)
                .background(
                    message.role == .user ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(Color(.secondarySystemBackground)),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
