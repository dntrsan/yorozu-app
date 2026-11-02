import SwiftUI

struct SettingsView: View {
    static var versionString: String {
        let info = Bundle.main.infoDictionary
        let ver = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "v\(ver) (build \(build))"
    }

    @AppStorage(Prefs.systemPrompt) private var systemPrompt = Prefs.defaultSystemPrompt
    @AppStorage(Prefs.temperature) private var temperature = 0.7
    @AppStorage(Prefs.maxTokens) private var maxTokens = 1024
    @AppStorage(Prefs.contextSize) private var contextSize = Prefs.defaultContextSize

    var body: some View {
        NavigationStack {
            Form {
                Section("システムプロンプト") {
                    TextEditor(text: $systemPrompt)
                        .frame(minHeight: 120)
                    Button("初期値に戻す") { systemPrompt = Prefs.defaultSystemPrompt }
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
            .navigationTitle("設定")
        }
    }
}
