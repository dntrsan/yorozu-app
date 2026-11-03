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
            ModelsView(store: store, chat: chat)
                .tabItem { Label("モデル", systemImage: "externaldrive") }
                .tag(AppTab.models)
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .glassTabBar()
        // 入力欄以外をタップしたらキーボードを下げる
        .background(KeyboardDismissOnTap().frame(width: 0, height: 0))
        // 使うモデルを決める(読み込みはチャットを開いた時)
        .task(id: "\(store.selectedURL?.path ?? "")|\(contextSize)") {
            await chat.configure(url: store.selectedURL, contextSize: contextSize)
            if tab == .chat, scenePhase == .active { await chat.ensureLoaded() }
        }
        .onChange(of: tab) {
            if tab == .chat { Task { await chat.ensureLoaded() } }
        }
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .active:
                store.refresh()
                LiveActivityManager.shared.ensureRunning()
                if tab == .chat { Task { await chat.ensureLoaded() } }
            case .background:
                // 裏ではGPUが使えないので生成は止める。モデルも外して端末のメモリを空ける
                chat.stop()
                if !UserDefaults.standard.bool(forKey: Prefs.keepModelInBackground) {
                    Task { await chat.release() }
                }
            default:
                // .inactive(コントロールセンター等)では生成だけ止める
                chat.stop()
            }
        }
        // iOS が「メモリが足りない」と言ってきたら、生成中でなければモデルを外す
        // 警告はまだ余裕がある時にも来るので、本当に残りが少ない時だけ外す
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            guard !chat.isGenerating, MemoryInfo.available < 350 * 1024 * 1024 else { return }
            Task { await chat.release(note: "メモリが足りなくなったから、モデルをいったん外しただ。話しかけるとまた読み込むだ") }
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
