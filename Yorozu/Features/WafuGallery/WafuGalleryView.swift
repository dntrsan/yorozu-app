import SwiftUI

/// 和風 SwiftUI 見本帳。画面案と部品案を一覧から開いて、実機で見比べる。
/// 各案の本体は Screens/ と Parts/ に 1 ファイルずつ（wafu-swiftui から取り込んだもの）。
/// 作り手: 画面 01〜08・ボタン・カード・手順の印は Codex、ほかは Gemini。
struct WafuGalleryView: View {
    /// どのモデルが作った案か
    enum Maker: String, CaseIterable, Identifiable {
        case codex, gemini
        var id: String { rawValue }
        var name: String {
            switch self {
            case .codex: return "Codex"
            case .gemini: return "Gemini"
            }
        }
        var model: String {
            switch self {
            case .codex: return "GPT-6 Astra"
            case .gemini: return "Gemini 4 Neon"
            }
        }
        var color: Color {
            switch self {
            case .codex: return Color(red: 0.06, green: 0.55, blue: 0.43)
            case .gemini: return Color(red: 0.26, green: 0.42, blue: 0.95)
            }
        }
        var symbol: String {
            switch self {
            case .codex: return "chevron.left.forwardslash.chevron.right"
            case .gemini: return "sparkle"
            }
        }
    }

    private struct Entry: Identifiable {
        let id: String
        let title: String
        let note: String
        let tint: Color
        let maker: Maker
        let make: () -> AnyView
    }

    @State private var filter: Maker? = nil

    private let screens: [Entry] = [
        Entry(id: "01", title: "墨と和紙", note: "生成りに墨一色、明朝と余白", tint: Color(red: 0.16, green: 0.15, blue: 0.13), maker: .codex) { AnyView(Wafu01Screen()) },
        Entry(id: "02", title: "藍染", note: "濃淡の藍と絞りのにじみ", tint: Color(red: 0.11, green: 0.20, blue: 0.38), maker: .codex) { AnyView(Wafu02Screen()) },
        Entry(id: "03", title: "漆と朱", note: "漆黒に朱、金の蒔絵線", tint: Color(red: 0.70, green: 0.16, blue: 0.12), maker: .codex) { AnyView(Wafu03Screen()) },
        Entry(id: "04", title: "桜と春霞", note: "淡い桜色と霞の層", tint: Color(red: 0.91, green: 0.62, blue: 0.68), maker: .codex) { AnyView(Wafu04Screen()) },
        Entry(id: "05", title: "枯山水と苔", note: "砂紋と苔の深緑", tint: Color(red: 0.27, green: 0.38, blue: 0.24), maker: .codex) { AnyView(Wafu05Screen()) },
        Entry(id: "06", title: "縁日の夜", note: "濃紺に提灯の灯り", tint: Color(red: 0.93, green: 0.52, blue: 0.20), maker: .codex) { AnyView(Wafu06Screen()) },
        Entry(id: "07", title: "浮世絵の波", note: "ベロ藍と青海波、版画の線", tint: Color(red: 0.12, green: 0.27, blue: 0.50), maker: .codex) { AnyView(Wafu07Screen()) },
        Entry(id: "08", title: "金屏風", note: "金箔の格子と屏風の折れ", tint: Color(red: 0.78, green: 0.62, blue: 0.27), maker: .codex) { AnyView(Wafu08Screen()) },
        Entry(id: "09", title: "侘び寂び", note: "土壁と焼き物、不揃いの角", tint: Color(red: 0.55, green: 0.45, blue: 0.36), maker: .gemini) { AnyView(Wafu09Screen()) },
        Entry(id: "10", title: "縦書きの古書", note: "縦組みと和綴じ", tint: Color(red: 0.60, green: 0.20, blue: 0.16), maker: .gemini) { AnyView(Wafu10Screen()) },
        Entry(id: "11", title: "組子と白木", note: "組子格子と檜の木肌", tint: Color(red: 0.80, green: 0.66, blue: 0.47), maker: .gemini) { AnyView(Wafu11Screen()) },
        Entry(id: "12", title: "紅葉", note: "深紅から黄朽葉へ", tint: Color(red: 0.72, green: 0.22, blue: 0.13), maker: .gemini) { AnyView(Wafu12Screen()) },
        Entry(id: "13", title: "雪と銀", note: "白と銀鼠、雪輪紋", tint: Color(red: 0.62, green: 0.66, blue: 0.70), maker: .gemini) { AnyView(Wafu13Screen()) },
        Entry(id: "14", title: "和サイバー", note: "夜の東京、ネオンの漢字", tint: Color(red: 0.95, green: 0.20, blue: 0.55), maker: .gemini) { AnyView(Wafu14Screen()) },
        Entry(id: "15", title: "千代紙ポップ", note: "千代紙の柄を大胆に", tint: Color(red: 0.90, green: 0.35, blue: 0.40), maker: .gemini) { AnyView(Wafu15Screen()) },
        Entry(id: "16", title: "家紋と判子", note: "家紋の幾何と朱肉", tint: Color(red: 0.75, green: 0.14, blue: 0.12), maker: .gemini) { AnyView(Wafu16Screen()) },
    ]

    private let parts: [Entry] = [
        Entry(id: "buttons", title: "ボタン", note: "押したときの表情も", tint: .red, maker: .codex) { AnyView(WafuPartsButtonsGallery()) },
        Entry(id: "cards", title: "カード", note: "和紙・漆・木・布の地", tint: .brown, maker: .codex) { AnyView(WafuPartsCardsGallery()) },
        Entry(id: "step-marks", title: "手順の印", note: "判子・漢数字・算木", tint: .orange, maker: .codex) { AnyView(WafuPartsStepMarksGallery()) },
        Entry(id: "headings", title: "見出しと区切り", note: "見出し・飾り罫", tint: .gray, maker: .gemini) { AnyView(WafuPartsHeadingsGallery()) },
        Entry(id: "patterns", title: "伝統文様", note: "青海波・麻の葉ほか 8 種", tint: .indigo, maker: .gemini) { AnyView(WafuPartsPatternsGallery()) },
        Entry(id: "status", title: "状態表示", note: "灯籠・朱印・水引", tint: .green, maker: .gemini) { AnyView(WafuPartsStatusGallery()) },
        Entry(id: "chips", title: "タグとトグル", note: "札・千社札・のし紙", tint: .pink, maker: .gemini) { AnyView(WafuPartsChipsTogglesGallery()) },
        Entry(id: "marks", title: "アプリのマーク", note: "家紋風・落款風・円相", tint: .teal, maker: .gemini) { AnyView(WafuPartsHeroMarksGallery()) },
    ]

    var body: some View {
        List {
            Section {
                Picker("作り手", selection: $filter.wafuHaptic()) {
                    Text("すべて").tag(Maker?.none)
                    ForEach(Maker.allCases) { m in
                        Text(m.name).tag(Maker?.some(m))
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            } footer: {
                HStack(spacing: 12) {
                    ForEach(Maker.allCases) { m in
                        Label("\(m.name) = \(m.model)", systemImage: m.symbol)
                            .foregroundStyle(m.color)
                    }
                }
                .font(.caption2)
            }
            Section {
                ForEach(screens.filter(shown)) { row($0, number: $0.id) }
            } header: {
                Text("画面案")
            } footer: {
                Text("架空の読書アプリ「よみび」の設定画面を、テーマ別に作った案")
            }
            Section("部品案") {
                ForEach(parts.filter(shown)) { row($0, number: nil) }
            }
        }
        .navigationTitle("和風見本帳")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shown(_ entry: Entry) -> Bool {
        filter == nil || entry.maker == filter
    }

    private func row(_ entry: Entry, number: String?) -> some View {
        NavigationLink {
            entry.make()
                .navigationTitle(entry.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        MakerBadge(maker: entry.maker, showModel: true, plain: true)
                    }
                }
                .onAppear { WafuHaptics.soft() }
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
                Spacer(minLength: 8)
                MakerBadge(maker: entry.maker, showModel: false)
            }
            .padding(.vertical, 2)
        }
    }
}

/// 作ったモデルの札
private struct MakerBadge: View {
    let maker: WafuGalleryView.Maker
    let showModel: Bool
    /// ツールバー用。iOS 26 はツールバーの項目を自前のガラスで包むので、こちらの枠は付けない
    var plain = false

    var body: some View {
        if plain {
            label
                .padding(.horizontal, 4)
                .fixedSize()
        } else {
            label
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(maker.color.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(maker.color.opacity(0.35), lineWidth: 1))
        }
    }

    private var label: some View {
        HStack(spacing: 4) {
            Image(systemName: maker.symbol)
                .font(.system(size: plain ? 11 : 9, weight: .bold))
            Text(showModel ? "\(maker.name) · \(maker.model)" : maker.name)
                .font(.system(size: plain ? 13 : 11, weight: .semibold))
        }
        .foregroundStyle(maker.color)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("作成: \(maker.name) \(maker.model)")
    }
}

#Preview {
    NavigationStack { WafuGalleryView() }
}
