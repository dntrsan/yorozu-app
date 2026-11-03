import SwiftUI
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    /// アプリが落ちてる間にダウンロードが終わると、iOS がここ経由で起こしてくれる
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        guard identifier == BackgroundDownloader.identifier else { completionHandler(); return }
        BackgroundDownloader.shared.backgroundCompletionHandler = completionHandler
        _ = ModelStore.shared              // コールバックを繋いでから
        _ = BackgroundDownloader.shared.session  // session を作り直してイベントを受け取る
    }
}

@main
struct YorozuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

enum AppTab: Hashable { case home, chat, models, settings }

/// 機能を増やす時は、Features/ 配下にフォルダを足して、ここの TabView にタブを1つ足すだけ。
struct RootView: View {
    @State private var chat = ChatViewModel()
    @State private var tab: AppTab = .home
    private let store = ModelStore.shared
    @AppStorage(Prefs.contextSize) private var contextSize = Prefs.defaultContextSize
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $tab) {
            HomeView(chat: chat, store: store, tab: $tab)
                .tabItem { Label("ホーム", systemImage: "square.grid.2x2.fill") }
                .tag(AppTab.home)
            ChatView(vm: chat)
                .tabItem { Label("チャット", systemImage: "bubble.left.and.bubble.right") }
                .tag(AppTab.chat)
            ModelsView(store: store)
                .tabItem { Label("モデル", systemImage: "externaldrive") }
                .tag(AppTab.models)
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .glassTabBar()
        // 入力欄以外をタップしたらキーボードを下げる
        .background(KeyboardDismissOnTap().frame(width: 0, height: 0))
        // モデルを選び直した/コンテキスト長を変えた時に読み込み直す
        .task(id: "\(store.selectedURL?.path ?? "")|\(contextSize)") {
            await chat.loadModel(at: store.selectedURL, contextSize: contextSize)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                store.refresh()
                LiveActivityManager.shared.ensureRunning()
            } else {
                // iOS はバックグラウンドからのGPU処理を許さず落ちるので、裏に回ったら生成を止める
                chat.stop()
            }
        }
        // ダイナミックアイランドをタップした時
        .onOpenURL { url in
            guard url.scheme == "yorozu" else { return }
            switch url.host {
            case "models": tab = .models
            case "home": tab = .home
            default: tab = .chat
            }
        }
    }
}
