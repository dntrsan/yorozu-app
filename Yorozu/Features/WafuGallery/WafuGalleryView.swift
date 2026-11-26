import SwiftUI

/// 和風 SwiftUI 見本帳。画面案と部品案を一覧から開いて、実機で見比べる。
/// 各案の本体は Screens/ と Parts/ に 1 ファイルずつ（wafu-swiftui から取り込んだもの）。
struct WafuGalleryView: View {
    private struct Entry: Identifiable {
        let id: String
        let title: String
        let note: String
        let tint: Color
        let make: () -> AnyView
    }

    private let screens: [Entry] = [
        Entry(id: "01", title: "墨と和紙", note: "生成りに墨一色、明朝と余白", tint: Color(red: 0.16, green: 0.15, blue: 0.13)) { AnyView(Wafu01Screen()) },
        Entry(id: "02", title: "藍染", note: "濃淡の藍と絞りのにじみ", tint: Color(red: 0.11, green: 0.20, blue: 0.38)) { AnyView(Wafu02Screen()) },
        Entry(id: "03", title: "漆と朱", note: "漆黒に朱、金の蒔絵線", tint: Color(red: 0.70, green: 0.16, blue: 0.12)) { AnyView(Wafu03Screen()) },
        Entry(id: "04", title: "桜と春霞", note: "淡い桜色と霞の層", tint: Color(red: 0.91, green: 0.62, blue: 0.68)) { AnyView(Wafu04Screen()) },
        Entry(id: "05", title: "枯山水と苔", note: "砂紋と苔の深緑", tint: Color(red: 0.27, green: 0.38, blue: 0.24)) { AnyView(Wafu05Screen()) },
        Entry(id: "06", title: "縁日の夜", note: "濃紺に提灯の灯り", tint: Color(red: 0.93, green: 0.52, blue: 0.20)) { AnyView(Wafu06Screen()) },
        Entry(id: "07", title: "浮世絵の波", note: "ベロ藍と青海波、版画の線", tint: Color(red: 0.12, green: 0.27, blue: 0.50)) { AnyView(Wafu07Screen()) },
        Entry(id: "08", title: "金屏風", note: "金箔の格子と屏風の折れ", tint: Color(red: 0.78, green: 0.62, blue: 0.27)) { AnyView(Wafu08Screen()) },
        Entry(id: "09", title: "侘び寂び", note: "土壁と焼き物、不揃いの角", tint: Color(red: 0.55, green: 0.45, blue: 0.36)) { AnyView(Wafu09Screen()) },
        Entry(id: "10", title: "縦書きの古書", note: "縦組みと和綴じ", tint: Color(red: 0.60, green: 0.20, blue: 0.16)) { AnyView(Wafu10Screen()) },
        Entry(id: "11", title: "組子と白木", note: "組子格子と檜の木肌", tint: Color(red: 0.80, green: 0.66, blue: 0.47)) { AnyView(Wafu11Screen()) },
        Entry(id: "12", title: "紅葉", note: "深紅から黄朽葉へ", tint: Color(red: 0.72, green: 0.22, blue: 0.13)) { AnyView(Wafu12Screen()) },
        Entry(id: "13", title: "雪と銀", note: "白と銀鼠、雪輪紋", tint: Color(red: 0.62, green: 0.66, blue: 0.70)) { AnyView(Wafu13Screen()) },
        Entry(id: "14", title: "和サイバー", note: "夜の東京、ネオンの漢字", tint: Color(red: 0.95, green: 0.20, blue: 0.55)) { AnyView(Wafu14Screen()) },
        Entry(id: "15", title: "千代紙ポップ", note: "千代紙の柄を大胆に", tint: Color(red: 0.90, green: 0.35, blue: 0.40)) { AnyView(Wafu15Screen()) },
        Entry(id: "16", title: "家紋と判子", note: "家紋の幾何と朱肉", tint: Color(red: 0.75, green: 0.14, blue: 0.12)) { AnyView(Wafu16Screen()) },
    ]

    private let parts: [Entry] = [
        Entry(id: "buttons", title: "ボタン", note: "押したときの表情も", tint: .red) { AnyView(WafuPartsButtonsGallery()) },
        Entry(id: "cards", title: "カード", note: "和紙・漆・木・布の地", tint: .brown) { AnyView(WafuPartsCardsGallery()) },
        Entry(id: "step-marks", title: "手順の印", note: "判子・漢数字・算木", tint: .orange) { AnyView(WafuPartsStepMarksGallery()) },
        Entry(id: "headings", title: "見出しと区切り", note: "見出し・飾り罫", tint: .gray) { AnyView(WafuPartsHeadingsGallery()) },
        Entry(id: "patterns", title: "伝統文様", note: "青海波・麻の葉ほか 8 種", tint: .indigo) { AnyView(WafuPartsPatternsGallery()) },
        Entry(id: "status", title: "状態表示", note: "灯籠・朱印・水引", tint: .green) { AnyView(WafuPartsStatusGallery()) },
        Entry(id: "chips", title: "タグとトグル", note: "札・千社札・のし紙", tint: .pink) { AnyView(WafuPartsChipsTogglesGallery()) },
        Entry(id: "marks", title: "アプリのマーク", note: "家紋風・落款風・円相", tint: .teal) { AnyView(WafuPartsHeroMarksGallery()) },
    ]

    var body: some View {
        List {
            Section {
                ForEach(screens) { row($0, number: $0.id) }
            } header: {
                Text("画面案")
            } footer: {
                Text("架空の読書アプリ「よみび」の設定画面を、テーマ別に作った案")
            }
            Section("部品案") {
                ForEach(parts) { row($0, number: nil) }
            }
        }
        .navigationTitle("和風見本帳")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ entry: Entry, number: String?) -> some View {
        NavigationLink {
            entry.make()
                .navigationTitle(entry.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(entry.tint.gradient)
                    .frame(width: 36, height: 36)
                    .overlay {
                        if let number {
                            Text(number)
                                .font(.system(size: 13, weight: .bold, design: .serif))
                                .foregroundStyle(.white)
                        }
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.custom("HiraMinProN-W6", size: 16))
                    Text(entry.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    NavigationStack { WafuGalleryView() }
}
