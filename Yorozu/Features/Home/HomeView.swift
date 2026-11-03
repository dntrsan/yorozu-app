import SwiftUI
import os

struct HomeView: View {
    var chat: ChatViewModel
    var store: ModelStore
    @Binding var tab: AppTab

    private let conversations = ConversationStore.shared
    @State private var path = NavigationPath()
    @AppStorage(Prefs.islandEnabled) private var islandEnabled = false

    private let columns = [GridItem(.adaptive(minimum: 72, maximum: 96), spacing: 16)]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    statusCard
                    appsSection
                    recentSection
                }
                .padding()
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .history:
                    HistoryView(vm: chat) { tab = .chat }
                }
            }
        }
    }

    // MARK: - Header

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 4..<11: return "おはよう"
        case 11..<18: return "こんにちは"
        default: return "こんばんは"
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), format: .dateTime.month().day().weekday(.wide))
                .font(.subheadline).foregroundStyle(.secondary)
            Text("\(greeting)、よろずだべ").font(.largeTitle.bold())
        }
    }

    // MARK: - Status

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: engineSymbol)
                    .font(.title2)
                    .foregroundStyle(engineColor)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(engineTitle).font(.headline)
                    Text(engineDetail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                if case .noModel = chat.state {
                    Button("入れる") { tab = .models }.glassButtonStyle(prominent: true)
                } else if chat.isReady {
                    Button("話す") { tab = .chat }.glassButtonStyle(prominent: true)
                }
            }

            ForEach(store.downloadProgress.keys.sorted(), id: \.self) { name in
                let p = store.downloadProgress[name] ?? 0
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label(name.replacingOccurrences(of: ".gguf", with: ""), systemImage: "arrow.down.circle")
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(p * 100))%").monospacedDigit()
                    }
                    .font(.caption)
                    ProgressView(value: p)
                }
            }

            Divider()
            HStack(spacing: 16) {
                stat("メモリ残り", Self.gb(UInt64(os_proc_available_memory())), "memorychip")
                stat("会話", "\(conversations.conversations.count)件", "bubble.left")
                stat("常駐", islandEnabled ? "オン" : "オフ", "capsule.inset.filled")
            }
        }
        .padding(16)
        .yorozuGlass(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func stat(_ title: String, _ value: String, _ symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: symbol).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static func gb(_ bytes: UInt64) -> String {
        String(format: "%.1fGB", Double(bytes) / 1_073_741_824)
    }

    private var engineTitle: String {
        switch chat.state {
        case .noModel: return "モデルが入ってないだ"
        case .loading: return "モデル読み込み中…"
        case .ready: return chat.isGenerating ? "考え中…" : "準備できてるだ"
        case .failed: return "読み込みに失敗しただ"
        }
    }

    private var engineDetail: String {
        switch chat.state {
        case .noModel: return "「モデル」からダウンロードしてけろ"
        case .loading(let n), .ready(let n): return n.replacingOccurrences(of: ".gguf", with: "")
        case .failed(let m): return m
        }
    }

    private var engineSymbol: String {
        switch chat.state {
        case .noModel: return "tray"
        case .loading: return "hourglass"
        case .ready: return chat.isGenerating ? "ellipsis.bubble.fill" : "sparkles"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    private var engineColor: Color {
        switch chat.state {
        case .noModel: return .orange
        case .loading: return .blue
        case .ready: return chat.isGenerating ? .purple : .green
        case .failed: return .red
        }
    }

    // MARK: - Apps

    private var appsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("アプリ").font(.title3.bold())
            LazyVGrid(columns: columns, alignment: .leading, spacing: 18) {
                ForEach(MiniApp.all) { app in
                    Button { open(app) } label: { AppTile(app: app) }
                        .buttonStyle(.plain)
                }
            }
        }
    }

    private func open(_ app: MiniApp) {
        switch app.destination {
        case .tab(let t): tab = t
        case .route(let r): path.append(r)
        }
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentSection: some View {
        if !conversations.conversations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("最近の会話").font(.title3.bold())
                    Spacer()
                    Button("すべて") { path.append(HomeRoute.history) }.font(.subheadline)
                }
                VStack(spacing: 0) {
                    ForEach(Array(conversations.conversations.prefix(3).enumerated()), id: \.element.id) { i, c in
                        if i > 0 { Divider().padding(.leading, 16) }
                        Button {
                            chat.open(c)
                            tab = .chat
                        } label: {
                            ConversationRow(conversation: c, isCurrent: c.id == chat.conversationID)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .yorozuGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

struct AppTile: View {
    let app: MiniApp

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: app.symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(colors: [app.color.opacity(0.75), app.color],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: app.color.opacity(0.3), radius: 6, y: 3)
            Text(app.title)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
