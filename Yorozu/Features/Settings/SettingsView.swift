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
    @AppStorage(Prefs.keepModelInBackground) private var keepModelInBackground = false
    /// 許可状態の確認はシステムに問い合わせるので、描画のたびではなく表示時だけにする
    @State private var activitiesAllowed = true
    @Bindable private var profile = ProfileStore.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        ProfileIconPicker(profile: profile, size: 60)
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("呼び方（任意）", text: $profile.name)
                                .textContentType(.nickname)
                                .font(.headline)
                            Text(profile.icon == nil ? "アイコンをタップして写真を選ぶ" : "長押しでアイコンを外せます")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("プロフィール")
                } footer: {
                    Text("ホームのあいさつで使うだ。この端末の中にだけ保存するだ。")
                }

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
                    Toggle("裏に回してもモデルを残す", isOn: $keepModelInBackground)
                    Picker("コンテキスト長", selection: $contextSize) {
                        Text("2048").tag(2048)
                        Text("4096").tag(4096)
                        Text("8192").tag(8192)
                    }
                } footer: {
                    Text("モデルはチャットを開いた時に読み込んで、アプリを裏に回すと外すだ(端末全体が重くならないように)。残すと戻った時すぐ話せるけど、他のアプリも含めて重くなりやすいだ。コンテキスト長は大きいほどメモリを食うだ。")
                }
                Section("このアプリについて") {
                    LabeledContent("バージョン", value: Self.versionString)
                    LabeledContent("作った人", value: AppCredit.author)
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
