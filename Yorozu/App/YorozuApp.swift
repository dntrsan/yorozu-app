import SwiftUI

@main
struct YorozuApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// 機能を増やす時は、Features/ 配下にフォルダを足して、ここの TabView にタブを1つ足すだけ。
struct RootView: View {
    @State private var chat = ChatViewModel()
    private let store = ModelStore.shared
    @AppStorage(Prefs.contextSize) private var contextSize = 4096
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            ChatView(vm: chat)
                .tabItem { Label("チャット", systemImage: "bubble.left.and.bubble.right") }
            ModelsView(store: store)
                .tabItem { Label("モデル", systemImage: "externaldrive") }
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
        // モデルを選び直した/コンテキスト長を変えた時に読み込み直す
        .task(id: "\(store.selectedURL?.path ?? "")|\(contextSize)") {
            await chat.loadModel(at: store.selectedURL, contextSize: contextSize)
        }
        // iOS はバックグラウンドからのGPU処理を許さず落ちるので、裏に回ったら生成を止める
        .onChange(of: scenePhase) {
            if scenePhase != .active { chat.stop() }
        }
    }
}
