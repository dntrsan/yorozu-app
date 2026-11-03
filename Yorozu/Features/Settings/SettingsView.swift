import SwiftUI

struct SettingsView: View {
    static var versionString: String {
        let info = Bundle.main.infoDictionary
        let ver = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "v\(ver) (build \(build))"
    }

    @AppStorage(Prefs.temperature) private var temperature = 0.7
    @AppStorage(Prefs.maxTokens) private var maxTokens = 1024
    @AppStorage(Prefs.contextSize) private var contextSize = Prefs.defaultContextSize
    @AppStorage(Prefs.islandEnabled) private var islandEnabled = false
    /// 許可状態の確認はシステムに問い合わせるので、描画のたびではなく表示時だけにする
    @State private var activitiesAllowed = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $islandEnabled) {
                        Label("ダイナミックアイランド常駐", systemImage: "capsule.inset.filled")
                    }
                    .onChange(of: islandEnabled) {
                        LiveActivityManager.shared.setEnabled(islandEnabled)
                    }
                } header: {
                    Text("常駐モード")
                } footer: {
                    if activitiesAllowed {
                        Text("アプリを閉じてもダイナミックアイランドとロック画面に、モデルの状態・返答・ダウンロード進捗を出すだ。iOSの決まりで8時間で消えるけど、アプリを開けばまた出るだ。")
                    } else {
                        Text("iPhoneの「設定 → よろず → ライブアクティビティ」がオフになってるだ。オンにしてけろ。")
                    }
                }

                Section("システムプロンプト") {
                    SystemPromptEditor()
                }
                Section("生成") {
                    VStack(alignment: .leading) {
                        Text("温度: \(temperature, specifier: "%.2f")")
                        Slider(value: $temperature, in: 0...1.5, step: 0.05)
                    }
                    Stepper("最大出力トークン: \(maxTokens)", value: $maxTokens, in: 128...4096, step: 128)
                }
                Section {
                    Picker("コンテキスト長", selection: $contextSize) {
                        Text("2048").tag(2048)
                        Text("4096").tag(4096)
                        Text("8192").tag(8192)
                    }
                } footer: {
                    Text("大きいほどメモリを食うだ。変えるとモデルを読み込み直すだ。落ちる時は小さくしてけろ。")
                }
                Section("このアプリについて") {
                    LabeledContent("バージョン", value: Self.versionString)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("設定")
            .onAppear { activitiesAllowed = LiveActivityManager.shared.isSystemAllowed }
        }
    }
}

/// 打っている文字はこの中だけで持ち、保存は打ち終わって0.5秒後にまとめて行う
/// (1文字ごとに保存して設定画面全体を描き直すと重いため)
private struct SystemPromptEditor: View {
    @State private var draft = UserDefaults.standard.string(forKey: Prefs.systemPrompt) ?? Prefs.defaultSystemPrompt
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        TextEditor(text: $draft)
            .frame(minHeight: 120)
            .onChange(of: draft) {
                saveTask?.cancel()
                let text = draft
                saveTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    guard !Task.isCancelled else { return }
                    UserDefaults.standard.set(text, forKey: Prefs.systemPrompt)
                }
            }
            .onDisappear {
                saveTask?.cancel()
                UserDefaults.standard.set(draft, forKey: Prefs.systemPrompt)
            }
        Button("初期値に戻す") { draft = Prefs.defaultSystemPrompt }
    }
}
