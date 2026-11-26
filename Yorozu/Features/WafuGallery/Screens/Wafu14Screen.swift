import SwiftUI

// MARK: - 14_neon-yoru: 和サイバー・夜の東京

struct Wafu14Screen: View {
    enum ExtState {
        case on, off, checking

        var next: ExtState {
            switch self {
            case .on: return .checking
            case .checking: return .off
            case .off: return .on
            }
        }

        var badgeText: String {
            switch self {
            case .on: return "オン"
            case .off: return "オフ"
            case .checking: return "確認中"
            }
        }

        var kanjiStamp: String {
            switch self {
            case .on: return "稼働"
            case .off: return "停止"
            case .checking: return "照会"
            }
        }

        var titleText: String {
            switch self {
            case .on: return "拡張機能はオンです"
            case .off: return "拡張機能はオフです"
            case .checking: return "拡張の状態を確認中…"
            }
        }

        var detailText: String {
            switch self {
            case .on: return "Safari で記事を開き、「ぁあ」から呼び出せます"
            case .off: return "設定アプリから「よみび」をオンにしてください"
            case .checking: return "Safari の機能拡張を読み込んでいます"
            }
        }

        var accentColor: Color {
            switch self {
            case .on: return Wafu14Palette.neonCyan
            case .off: return Wafu14Palette.mutedSlate
            case .checking: return Wafu14Palette.neonAmber
            }
        }
    }

    @State private var extState: ExtState = .on
    @State private var neonBreath: Bool = false

    var body: some View {
        ZStack {
            Wafu14Backdrop(neonBreath: neonBreath)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Wafu14HeroSection(neonBreath: neonBreath)
                        .padding(.top, 26)
                        .padding(.bottom, 24)

                    Wafu14StatusCard(state: extState, neonBreath: neonBreath) {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            extState = extState.next
                        }
                    }
                    .padding(.bottom, 26)

                    Wafu14FeaturesSection()
                        .padding(.bottom, 28)

                    Wafu14StepsSection()
                        .padding(.bottom, 16)

                    Wafu14NoticeCard()
                        .padding(.bottom, 26)

                    Wafu14PrimaryButton()
                        .padding(.bottom, 30)

                    Wafu14Footer()
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 440)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                neonBreath = true
            }
        }
    }
}

// MARK: - Palette

private enum Wafu14Palette {
    static let nightTop     = Color(wafu14Hex: 0x080A0F) // 漆黒
    static let nightBottom  = Color(wafu14Hex: 0x0E121C) // 深夜藍黒
    static let panelBg      = Color(wafu14Hex: 0x111622) // 暗パネル
    static let panelRaised  = Color(wafu14Hex: 0x161D2C) // 浮きパネル
    static let emphCrimson  = Color(wafu14Hex: 0x1E101A) // 紅ネオン暗地
    static let noticeAmber  = Color(wafu14Hex: 0x1A150C) // 琥珀暗地
    static let borderDim    = Color(wafu14Hex: 0x253044) // 暗鉄枠
    static let textPrimary  = Color(wafu14Hex: 0xF1F5FA) // 白銀光文字
    static let textSub      = Color(wafu14Hex: 0xA6B4C8) // 銀灰文字
    static let mutedSlate   = Color(wafu14Hex: 0x627187) // 消灯灰
    static let neonCyan     = Color(wafu14Hex: 0x00E5D4) // 電光浅葱
    static let neonCrimson  = Color(wafu14Hex: 0xFF2E7E) // 電光紅梅
    static let neonAmber    = Color(wafu14Hex: 0xF5B73B) // 電光琥珀
    static let inkOnCyan    = Color(wafu14Hex: 0x061317) // シアン上の漆黒文字
}

private extension Color {
    init(wafu14Hex hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Typography

private enum Wafu14Font {
    static func mincho(_ size: CGFloat, bold: Bool = false) -> Font {
        Font.custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size)
    }

    static func gothic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Backdrop (夜の東京・縦の電光と微かなネオン滲み)

private struct Wafu14Backdrop: View {
    let neonBreath: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Wafu14Palette.nightTop, Wafu14Palette.nightBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    // 右上：紅看板の柔らかなネオン滲み
                    RadialGradient(
                        colors: [
                            Wafu14Palette.neonCrimson.opacity(neonBreath ? 0.16 : 0.09),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 190
                    )
                    .frame(width: 380, height: 380)
                    .position(x: geo.size.width * 0.92, y: 110)

                    // 左中ほど：電光シアンの淡い反射
                    RadialGradient(
                        colors: [
                            Wafu14Palette.neonCyan.opacity(0.09),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 210
                    )
                    .frame(width: 420, height: 420)
                    .position(x: geo.size.width * 0.08, y: geo.size.height * 0.56)

                    // 縦の電光ライン（東京の夜の縦軸）と極薄グリッド
                    Canvas { context, size in
                        // ごく薄い水平走査ライン（品よく控えめに）
                        let stepY: CGFloat = 28
                        var y: CGFloat = 0
                        while y < size.height {
                            var row = Path()
                            row.move(to: CGPoint(x: 0, y: y))
                            row.addLine(to: CGPoint(x: size.width, y: y))
                            context.stroke(row, with: .color(Color.white.opacity(0.022)), lineWidth: 0.5)
                            y += stepY
                        }

                        // 左端を走る極細の縦電光ライン（シアン）
                        let leftX: CGFloat = 9
                        var leftLine = Path()
                        leftLine.move(to: CGPoint(x: leftX, y: 40))
                        leftLine.addLine(to: CGPoint(x: leftX, y: size.height - 40))
                        context.stroke(
                            leftLine,
                            with: .linearGradient(
                                Gradient(colors: [
                                    Wafu14Palette.neonCyan.opacity(0.0),
                                    Wafu14Palette.neonCyan.opacity(0.35),
                                    Wafu14Palette.neonCyan.opacity(0.10),
                                    Wafu14Palette.neonCrimson.opacity(0.28),
                                    Wafu14Palette.neonCrimson.opacity(0.0)
                                ]),
                                startPoint: CGPoint(x: leftX, y: 40),
                                endPoint: CGPoint(x: leftX, y: size.height - 40)
                            ),
                            lineWidth: 1.0
                        )

                        // 右端を走る縦の電光ライン（紅）
                        let rightX: CGFloat = size.width - 9
                        var rightLine = Path()
                        rightLine.move(to: CGPoint(x: rightX, y: 24))
                        rightLine.addLine(to: CGPoint(x: rightX, y: size.height - 60))
                        context.stroke(
                            rightLine,
                            with: .linearGradient(
                                Gradient(colors: [
                                    Wafu14Palette.neonCrimson.opacity(0.0),
                                    Wafu14Palette.neonCrimson.opacity(0.42),
                                    Wafu14Palette.neonCrimson.opacity(0.08),
                                    Wafu14Palette.neonCyan.opacity(0.24),
                                    Wafu14Palette.neonCyan.opacity(0.0)
                                ]),
                                startPoint: CGPoint(x: rightX, y: 24),
                                endPoint: CGPoint(x: rightX, y: size.height - 60)
                            ),
                            lineWidth: 1.0
                        )
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Corner Brackets Overlay (和の隅金具のサイバー解釈)

private struct Wafu14CornerBrackets: View {
    let color: Color
    var length: CGFloat = 9
    var lineWidth: CGFloat = 1.25

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                // 左上
                p.move(to: CGPoint(x: 0, y: length))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: length, y: 0))
                // 右上
                p.move(to: CGPoint(x: w - length, y: 0))
                p.addLine(to: CGPoint(x: w, y: 0))
                p.addLine(to: CGPoint(x: w, y: length))
                // 左下
                p.move(to: CGPoint(x: 0, y: h - length))
                p.addLine(to: CGPoint(x: 0, y: h))
                p.addLine(to: CGPoint(x: length, y: h))
                // 右下
                p.move(to: CGPoint(x: w - length, y: h))
                p.addLine(to: CGPoint(x: w, y: h))
                p.addLine(to: CGPoint(x: w, y: h - length))
            }
            .stroke(color, lineWidth: lineWidth)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 1. Hero Section (左エディトリアル + 右の縦ネオン漢字看板)

private struct Wafu14HeroSection: View {
    let neonBreath: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Wafu14AppMark()
                    .frame(width: 66, height: 66)
                    .padding(.bottom, 16)

                Text("よみび")
                    .font(Wafu14Font.mincho(32, bold: true))
                    .tracking(6)
                    .foregroundStyle(Wafu14Palette.textPrimary)
                    .shadow(color: Wafu14Palette.neonCyan.opacity(0.32), radius: 10, x: 0, y: 0)
                    .padding(.bottom, 8)

                Text("ウェブの文章を、本のように読む")
                    .font(Wafu14Font.mincho(13.5))
                    .tracking(0.6)
                    .foregroundStyle(Wafu14Palette.textSub)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 16)

                HStack(spacing: 6) {
                    Wafu14TagChip(label: "v1.0", accent: Wafu14Palette.neonCyan)
                    Wafu14TagChip(label: "iOS 18+", accent: Wafu14Palette.textSub)
                    Wafu14TagChip(label: "Safari", accent: Wafu14Palette.neonCrimson)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 右袖：夜の東京の縦ネオン漢字看板
            Wafu14VerticalNeonSign(neonBreath: neonBreath)
        }
    }
}

private struct Wafu14AppMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(wafu14Hex: 0x141C2B), Color(wafu14Hex: 0x0A0E17)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Wafu14Palette.neonCyan, Wafu14Palette.neonCrimson],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.4
                )
                .shadow(color: Wafu14Palette.neonCyan.opacity(0.35), radius: 6, x: 0, y: 0)

            // 内側の電光和本＋縦のネオン栞光線
            Canvas { context, size in
                let cx = size.width * 0.5
                let cy = size.height * 0.5

                // 開いた書物の鋭角フレーム
                var leftPage = Path()
                leftPage.move(to: CGPoint(x: cx - 1, y: cy - 12))
                leftPage.addLine(to: CGPoint(x: cx - 16, y: cy - 15))
                leftPage.addLine(to: CGPoint(x: cx - 16, y: cy + 12))
                leftPage.addLine(to: CGPoint(x: cx - 1, y: cy + 15))
                leftPage.closeSubpath()

                var rightPage = Path()
                rightPage.move(to: CGPoint(x: cx + 1, y: cy - 12))
                rightPage.addLine(to: CGPoint(x: cx + 16, y: cy - 15))
                rightPage.addLine(to: CGPoint(x: cx + 16, y: cy + 12))
                rightPage.addLine(to: CGPoint(x: cx + 1, y: cy + 15))
                rightPage.closeSubpath()

                context.stroke(leftPage, with: .color(Wafu14Palette.textPrimary.opacity(0.92)), lineWidth: 1.35)
                context.stroke(rightPage, with: .color(Wafu14Palette.textPrimary.opacity(0.92)), lineWidth: 1.35)

                // 右頁の縦書き電光ライン
                let cols: [(CGFloat, CGFloat)] = [
                    (cx + 6.5, 13.0),
                    (cx + 11.2, 10.0),
                    (cx - 6.5, 12.0),
                    (cx - 11.2, 9.0)
                ]
                for (xPos, length) in cols {
                    var strokePath = Path()
                    strokePath.move(to: CGPoint(x: xPos, y: cy - 8.5))
                    strokePath.addLine(to: CGPoint(x: xPos, y: cy - 8.5 + length))
                    context.stroke(strokePath, with: .color(Wafu14Palette.neonCyan.opacity(0.88)), lineWidth: 1.2)
                }

                // 中央を貫く紅ネオンの縦の電光栞
                var beam = Path()
                beam.move(to: CGPoint(x: cx, y: cy - 18))
                beam.addLine(to: CGPoint(x: cx, y: cy + 20))
                context.stroke(beam, with: .color(Wafu14Palette.neonCrimson), lineWidth: 1.8)
            }
        }
    }
}

private struct Wafu14VerticalNeonSign: View {
    let neonBreath: Bool
    private let characters = ["明", "朝", "読", "書"]

    var body: some View {
        VStack(spacing: 4) {
            // 上部の小さな電光端子
            Capsule()
                .fill(Wafu14Palette.neonCrimson.opacity(0.85))
                .frame(width: 14, height: 2.5)
                .padding(.bottom, 4)

            ForEach(characters, id: \.self) { ch in
                Text(ch)
                    .font(Wafu14Font.mincho(18, bold: true))
                    .foregroundStyle(Color(wafu14Hex: 0xFFD9E8))
                    .shadow(
                        color: Wafu14Palette.neonCrimson.opacity(neonBreath ? 0.95 : 0.55),
                        radius: neonBreath ? 8 : 4,
                        x: 0,
                        y: 0
                    )
            }

            Rectangle()
                .fill(Wafu14Palette.neonCrimson.opacity(0.45))
                .frame(width: 16, height: 1)
                .padding(.vertical, 3)

            Text("夜")
                .font(Wafu14Font.mincho(11, bold: true))
                .foregroundStyle(Wafu14Palette.neonCyan)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(wafu14Hex: 0x120A12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(
                    Wafu14Palette.neonCrimson.opacity(neonBreath ? 0.92 : 0.62),
                    lineWidth: 1.2
                )
        )
        .shadow(
            color: Wafu14Palette.neonCrimson.opacity(neonBreath ? 0.36 : 0.16),
            radius: 12,
            x: 0,
            y: 0
        )
    }
}

private struct Wafu14TagChip: View {
    let label: String
    let accent: Color

    var body: some View {
        Text(label)
            .font(Wafu14Font.mono(10.5, weight: .semibold))
            .foregroundStyle(accent == Wafu14Palette.textSub ? Wafu14Palette.textSub : accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(accent.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(accent.opacity(0.42), lineWidth: 0.85)
            )
    }
}

// MARK: - 2. Status Card (縦の電光バー付きステータス)

private struct Wafu14StatusCard: View {
    let state: Wafu14Screen.ExtState
    let neonBreath: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 13) {
                // 漢字電光スタンプ
                VStack(spacing: 2) {
                    Text(state.kanjiStamp)
                        .font(Wafu14Font.mincho(12, bold: true))
                        .foregroundStyle(state.accentColor)
                    Circle()
                        .fill(state.accentColor)
                        .frame(width: 5, height: 5)
                        .opacity(state == .off ? 0.45 : (neonBreath ? 1.0 : 0.45))
                }
                .frame(width: 38, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(state.accentColor.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(state.accentColor.opacity(0.42), lineWidth: 0.9)
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(state.titleText)
                            .font(Wafu14Font.mincho(15, bold: true))
                            .foregroundStyle(Wafu14Palette.textPrimary)

                        Spacer(minLength: 4)

                        Text(state.badgeText)
                            .font(Wafu14Font.mono(10.5, weight: .bold))
                            .foregroundStyle(state == .on ? Wafu14Palette.inkOnCyan : state.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2.5)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(state == .on ? Wafu14Palette.neonCyan : state.accentColor.opacity(0.16))
                            )
                    }

                    Text(state.detailText)
                        .font(Wafu14Font.gothic(12))
                        .foregroundStyle(Wafu14Palette.textSub)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.leading, 26)
            .padding(.trailing, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Wafu14Palette.panelBg)
            )
            .overlay(alignment: .leading) {
                // 左の縦電光チューブ
                Capsule()
                    .fill(state.accentColor)
                    .frame(width: 3.5)
                    .padding(.vertical, 12)
                    .padding(.leading, 12)
                    .shadow(
                        color: state == .off ? Color.clear : state.accentColor.opacity(neonBreath ? 0.9 : 0.4),
                        radius: 6,
                        x: 0,
                        y: 0
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(state.accentColor.opacity(state == .off ? 0.35 : 0.45), lineWidth: 1.0)
            )
            .overlay(
                Wafu14CornerBrackets(color: state.accentColor.opacity(0.85), length: 8, lineWidth: 1.3)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("タップすると拡張の状態表示を切り替えます")
    }
}

// MARK: - Section Header

private struct Wafu14SectionHeader: View {
    let kanjiLabel: String
    let codeLabel: String
    var accent: Color = Wafu14Palette.neonCyan

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(accent)
                .frame(width: 3, height: 14)
                .shadow(color: accent.opacity(0.7), radius: 4, x: 0, y: 0)

            Text(kanjiLabel)
                .font(Wafu14Font.mincho(14, bold: true))
                .tracking(2.0)
                .foregroundStyle(Wafu14Palette.textPrimary)

            Rectangle()
                .fill(Wafu14Palette.borderDim)
                .frame(height: 1)

            Text(codeLabel)
                .font(Wafu14Font.mono(10, weight: .medium))
                .tracking(1.0)
                .foregroundStyle(Wafu14Palette.mutedSlate)
        }
    }
}

// MARK: - 3. Features (説明 3 行)

private struct Wafu14FeaturesSection: View {
    private let items: [(icon: String, text: String)] = [
        ("doc.plaintext", "本文だけを抜き出して明朝体で組む"),
        ("textformat.size", "行間と文字の大きさを端末に合わせる"),
        ("bookmark", "読んだ位置を覚えておく")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Wafu14SectionHeader(kanjiLabel: "電光仕様", codeLabel: "SPEC 03")

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 13) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Wafu14Palette.neonCyan.opacity(0.10))
                                .frame(width: 32, height: 32)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Wafu14Palette.neonCyan.opacity(0.38), lineWidth: 0.9)
                                .frame(width: 32, height: 32)
                            Image(systemName: item.icon)
                                .font(.system(size: 13.5, weight: .medium))
                                .foregroundStyle(Wafu14Palette.neonCyan)
                        }

                        Text(item.text)
                            .font(Wafu14Font.mincho(13.5))
                            .foregroundStyle(Wafu14Palette.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Wafu14Palette.borderDim.opacity(0.75))
                            .frame(height: 0.8)
                            .padding(.leading, 58)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Wafu14Palette.panelBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Wafu14Palette.borderDim, lineWidth: 1.0)
            )
        }
    }
}

// MARK: - 4. Steps Section (4手順・手順4を紅ネオン強調)

private struct Wafu14StepItem: Identifiable {
    let id: Int
    let code: String
    let kanji: String
    let title: String
    let note: String?
    let isEmphasized: Bool
}

private struct Wafu14StepsSection: View {
    private let steps: [Wafu14StepItem] = [
        Wafu14StepItem(
            id: 1,
            code: "01",
            kanji: "壱",
            title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
            note: "設定アプリのいちばん下のほう",
            isEmphasized: false
        ),
        Wafu14StepItem(
            id: 2,
            code: "02",
            kanji: "弐",
            title: "「よみび」をオンにする",
            note: nil,
            isEmphasized: false
        ),
        Wafu14StepItem(
            id: 3,
            code: "03",
            kanji: "参",
            title: "Safari で好きな記事を開く",
            note: nil,
            isEmphasized: false
        ),
        Wafu14StepItem(
            id: 4,
            code: "04",
            kanji: "肆",
            title: "アドレスバーの「ぁあ」から「よみび」を選ぶ",
            note: "ここで初めて本文が整う",
            isEmphasized: true
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Wafu14SectionHeader(
                kanjiLabel: "起動手順",
                codeLabel: "STEP 01—04",
                accent: Wafu14Palette.neonCrimson
            )

            VStack(spacing: 10) {
                ForEach(steps) { step in
                    Wafu14StepRow(step: step, isLast: step.id == steps.count)
                }
            }
        }
    }
}

private struct Wafu14StepRow: View {
    let step: Wafu14StepItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            // 左側の縦電光レールと標札番号
            VStack(spacing: 0) {
                VStack(spacing: 1) {
                    Text(step.kanji)
                        .font(Wafu14Font.mincho(13, bold: true))
                        .foregroundStyle(step.isEmphasized ? Color.white : Wafu14Palette.neonCyan)
                    Text(step.code)
                        .font(Wafu14Font.mono(8.5, weight: .bold))
                        .foregroundStyle(step.isEmphasized ? Color(wafu14Hex: 0xFFD2E4) : Wafu14Palette.mutedSlate)
                }
                .frame(width: 30, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(step.isEmphasized ? Wafu14Palette.neonCrimson : Wafu14Palette.panelRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(
                            step.isEmphasized ? Wafu14Palette.neonCrimson : Wafu14Palette.neonCyan.opacity(0.35),
                            lineWidth: 1.0
                        )
                )
                .shadow(
                    color: step.isEmphasized ? Wafu14Palette.neonCrimson.opacity(0.55) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 0
                )

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Wafu14Palette.neonCyan.opacity(0.45),
                                    step.id == 3 ? Wafu14Palette.neonCrimson.opacity(0.65) : Wafu14Palette.borderDim
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                        .frame(minHeight: 14, maxHeight: .infinity)
                        .padding(.top, 5)
                }
            }
            .frame(width: 30)

            // 手順本文パネル
            VStack(alignment: .leading, spacing: 5) {
                if step.isEmphasized {
                    HStack(spacing: 6) {
                        Text("要点")
                            .font(Wafu14Font.mincho(10.5, bold: true))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Wafu14Palette.neonCrimson)
                            )

                        Text("FINAL STEP")
                            .font(Wafu14Font.mono(10, weight: .semibold))
                            .tracking(1.0)
                            .foregroundStyle(Color(wafu14Hex: 0xFF8AB8))
                    }
                    .padding(.bottom, 1)
                }

                Text(step.title)
                    .font(Wafu14Font.mincho(step.isEmphasized ? 15 : 14, bold: step.isEmphasized))
                    .foregroundStyle(Wafu14Palette.textPrimary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if let note = step.note {
                    Text(note)
                        .font(Wafu14Font.gothic(12, weight: step.isEmphasized ? .medium : .regular))
                        .foregroundStyle(step.isEmphasized ? Color(wafu14Hex: 0xFF8AB8) : Wafu14Palette.textSub)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, step.isEmphasized ? 14 : 11)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(step.isEmphasized ? Wafu14Palette.emphCrimson : Wafu14Palette.panelBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        step.isEmphasized ? Wafu14Palette.neonCrimson.opacity(0.85) : Wafu14Palette.borderDim,
                        lineWidth: step.isEmphasized ? 1.3 : 0.95
                    )
            )
            .overlay {
                if step.isEmphasized {
                    Wafu14CornerBrackets(color: Wafu14Palette.neonCrimson, length: 9, lineWidth: 1.5)
                }
            }
            .shadow(
                color: step.isEmphasized ? Wafu14Palette.neonCrimson.opacity(0.22) : Color.clear,
                radius: 12,
                x: 0,
                y: 4
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 5. Notice Card (琥珀ネオンの注意標札)

private struct Wafu14NoticeCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Text("注")
                .font(Wafu14Font.mincho(13, bold: true))
                .foregroundStyle(Wafu14Palette.neonAmber)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Wafu14Palette.neonAmber.opacity(0.14))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Wafu14Palette.neonAmber.opacity(0.55), lineWidth: 0.9)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("サイトごとに許可が要る")
                    .font(Wafu14Font.mincho(13.5, bold: true))
                    .foregroundStyle(Color(wafu14Hex: 0xFFE3A3))

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(Wafu14Font.gothic(12.5))
                    .foregroundStyle(Wafu14Palette.textSub)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Wafu14Palette.noticeAmber)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Wafu14Palette.neonAmber.opacity(0.45), lineWidth: 1.0)
        )
    }
}

// MARK: - 6. Primary Button (電光シアン発光ボタン)

private struct Wafu14PrimaryButton: View {
    private let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        Link(destination: safariURL) {
            HStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 17, weight: .semibold))

                Text("Safari を開く")
                    .font(Wafu14Font.mincho(16.5, bold: true))
                    .tracking(2.0)

                Spacer(minLength: 0)

                Text("GO")
                    .font(Wafu14Font.mono(11, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Wafu14Palette.inkOnCyan.opacity(0.14))
                    )

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13.5, weight: .bold))
            }
            .foregroundStyle(Wafu14Palette.inkOnCyan)
            .padding(.horizontal, 20)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Wafu14Palette.neonCyan, Color(wafu14Hex: 0x35F2E6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Wafu14Palette.neonCyan.opacity(0.36), radius: 14, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                    .stroke(Wafu14Palette.inkOnCyan.opacity(0.24), lineWidth: 1.0)
                    .padding(3.5)
            )
        }
    }
}

// MARK: - 7. Footer

private struct Wafu14Footer: View {
    var body: some View {
        VStack(spacing: 12) {
            LinearGradient(
                colors: [
                    Color.clear,
                    Wafu14Palette.neonCyan.opacity(0.5),
                    Wafu14Palette.neonCrimson.opacity(0.5),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.horizontal, 32)

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(Wafu14Font.mincho(11.5))
                .tracking(0.8)
                .foregroundStyle(Wafu14Palette.mutedSlate)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    Wafu14Screen()
}
