import SwiftUI

struct ChatView: View {
    @Bindable var vm: ChatViewModel
    @State private var input = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusBanner
                messageList
                inputBar
            }
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
            banner("モデルが無いだ。「モデル」タブからダウンロードしてけろ", color: .orange)
        case .loading(let name):
            HStack(spacing: 8) {
                ProgressView()
                Text("読み込み中: \(name)").font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.blue.opacity(0.12))
        case .failed(let msg):
            banner(msg, color: .red)
        case .ready:
            EmptyView()
        }
    }

    private func banner(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(color.opacity(0.15))
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if vm.messages.isEmpty {
                        Text("なんでも聞いてけろ。\nこのiPhoneの中だけで動いてて、会話は外に出ないだ。")
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
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

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("メッセージ", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
            if vm.isGenerating {
                Button { vm.stop() } label: {
                    Image(systemName: "stop.circle.fill").font(.title)
                }
            } else {
                Button {
                    vm.send(input)
                    input = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title)
                }
                .disabled(!vm.isReady || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.content.isEmpty ? "…" : message.content)
                .textSelection(.enabled)
                .padding(10)
                .background(message.role == .user ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
