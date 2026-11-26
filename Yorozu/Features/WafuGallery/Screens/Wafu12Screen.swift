import SwiftUI

// MARK: - Wafu 12: 紅葉（秋の夕暮れ）

private extension Color {
    init(wafu12Hex: UInt32, alpha: Double = 1.0) {
        let r = Double((wafu12Hex >> 16) & 0xFF) / 255.0
        let g = Double((wafu12Hex >> 8) & 0xFF) / 255.0
        let b = Double(wafu12Hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum Wafu12Palette {
    static let bgDuskTop        = Color(wafu12Hex: 0x261616) // 宵茜暗
    static let bgDuskMid        = Color(wafu12Hex: 0x1A1211) // 黒鳶
    static let bgDuskBottom     = Color(wafu12Hex: 0x130D0C) // 墨茶
    static let surfaceCard      = Color(wafu12Hex: 0x231816) // 檜皮黒
    static let surfaceHighlight = Color(wafu12Hex: 0x301816) // 深紅霞
    static let surfaceNotice    = Color(wafu12Hex: 0x291E17) // 朽葉暗
    static let crimsonDeep      = Color(wafu12Hex: 0x9E2A2B) // 深緋
    static let autumnRed        = Color(wafu12Hex: 0xB5422D) // 紅茜
    static let persimmonGlow    = Color(wafu12Hex: 0xC86834) // 茜柿
    static let ochreLeaf        = Color(wafu12Hex: 0xD9A45B) // 黄朽葉
    static let textPrimary      = Color(wafu12Hex: 0xF3EAE0) // 月白暖
    static let textSecondary    = Color(wafu12Hex: 0xB7A596) // 薄朽葉
    static let textMuted        = Color(wafu12Hex: 0x867569) // 煤茶
    static let statusOn         = Color(wafu12Hex: 0x84A173) // 青楓
    static let statusOff        = Color(wafu12Hex: 0x8A7B72) // 灰鳶
    static let statusChecking   = Color(wafu12Hex: 0xD9A45B) // 黄朽葉

    static let autumnGradient = LinearGradient(
        colors: [crimsonDeep, persimmonGlow, ochreLeaf],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [crimsonDeep, Color(wafu12Hex: 0xBA4B2D), Color(wafu12Hex: 0xCB7C3B)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let horizontalFadeRule = LinearGradient(
        colors: [
            ochreLeaf.opacity(0.0),
            ochreLeaf.opacity(0.32),
            ochreLeaf.opacity(0.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

private enum Wafu12Font {
    static func minchoRegular(_ size: CGFloat) -> Font {
        Font.custom("HiraMinProN-W3", size: size)
    }

    static func minchoSemiBold(_ size: CGFloat) -> Font {
        Font.custom("HiraMinProN-W6", size: size)
    }

    static func gothic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

private struct Wafu12StepItem: Identifiable {
    let id: Int
    let title: String
    let note: String?
    let dotColor: Color
    let nextDotColor: Color?
    let isHighlighted: Bool
}

private struct Wafu12FeatureItem: Identifiable {
    let id: Int
    let symbol: String
    let text: String
}

private enum Wafu12Content {
    static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!
    static let tags = ["v1.0", "iOS 18+", "Safari"]

    static let steps: [Wafu12StepItem] = [
        Wafu12StepItem(
            id: 1,
            title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
            note: "設定アプリのいちばん下のほう",
            dotColor: Wafu12Palette.crimsonDeep,
            nextDotColor: Wafu12Palette.autumnRed,
            isHighlighted: false
        ),
        Wafu12StepItem(
            id: 2,
            title: "「よみび」をオンにする",
            note: nil,
            dotColor: Wafu12Palette.autumnRed,
            nextDotColor: Wafu12Palette.persimmonGlow,
            isHighlighted: false
        ),
        Wafu12StepItem(
            id: 3,
            title: "Safari で好きな記事を開く",
            note: nil,
            dotColor: Wafu12Palette.persimmonGlow,
            nextDotColor: Wafu12Palette.ochreLeaf,
            isHighlighted: false
        ),
        Wafu12StepItem(
            id: 4,
            title: "アドレスバーの「ぁあ」から「よみび」を選ぶ",
            note: "ここで初めて本文が整う",
            dotColor: Wafu12Palette.ochreLeaf,
            nextDotColor: nil,
            isHighlighted: true
        )
    ]

    static let features: [Wafu12FeatureItem] = [
        Wafu12FeatureItem(id: 1, symbol: "text.book.closed", text: "本文だけを抜き出して明朝体で組む"),
        Wafu12FeatureItem(id: 2, symbol: "textformat.size", text: "行間と文字の大きさを端末に合わせる"),
        Wafu12FeatureItem(id: 3, symbol: "bookmark", text: "読んだ位置を覚えておく")
    ]
}

// MARK: - Main Screen

struct Wafu12Screen: View {
    enum ExtState {
        case on, off, checking

        mutating func next() {
            switch self {
            case .on: self = .off
            case .off: self = .checking
            case .checking: self = .on
            }
        }

        var label: String {
            switch self {
            case .on: return "機能拡張はオン"
            case .off: return "機能拡張はオフ"
            case .checking: return "状態を確認中"
            }
        }

        var detail: String {
            switch self {
            case .on: return "秋の夜長のように、静かに本文を組めます"
            case .off: return "設定アプリから「よみび」を有効にしてください"
            case .checking: return "Safari 機能拡張の状態を確かめています…"
            }
        }

        var accentColor: Color {
            switch self {
            case .on: return Wafu12Palette.statusOn
            case .off: return Wafu12Palette.statusOff
            case .checking: return Wafu12Palette.statusChecking
            }
        }
    }

    @State private var extState: ExtState = .on
    @State private var duskBreathing: Bool = false
    @State private var statusPulse: Bool = false

    var body: some View {
        ZStack {
            Wafu12DuskBackground(isBreathing: duskBreathing)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                    statusSection
                    stepsSection
                    noticeSection
                    primaryActionSection
                    featuresSection
                    footerSection
                }
                .padding(.horizontal, 22)
                .padding(.top, 26)
                .padding(.bottom, 38)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                duskBreathing = true
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                statusPulse = true
            }
        }
    }

    // MARK: - 1. ヒーロー（夕暮れの中央揃え）

    private var heroSection: some View {
        VStack(spacing: 14) {
            Wafu12AppMark()
                .frame(width: 74, height: 74)
                .shadow(color: Wafu12Palette.crimsonDeep.opacity(0.32), radius: 18, x: 0, y: 8)

            VStack(spacing: 7) {
                Text("よみび")
                    .font(Wafu12Font.minchoSemiBold(30))
                    .tracking(6)
                    .foregroundStyle(Wafu12Palette.textPrimary)

                Text("ウェブの文章を、本のように読む")
                    .font(Wafu12Font.minchoRegular(13.5))
                    .tracking(1.0)
                    .foregroundStyle(Wafu12Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                ForEach(Wafu12Content.tags, id: \.self) { tag in
                    Text(tag)
                        .font(Wafu12Font.gothic(11, weight: .medium))
                        .tracking(0.8)
                        .foregroundStyle(Wafu12Palette.ochreLeaf.opacity(0.92))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Wafu12Palette.surfaceCard.opacity(0.85))
                        .overlay(
                            Capsule()
                                .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.24), lineWidth: 0.75)
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    // MARK: - 2. 状態表示カード

    private var statusSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                extState.next()
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(extState.accentColor.opacity(statusPulse ? 0.28 : 0.08))
                        .frame(width: 28, height: 28)
                        .scaleEffect(statusPulse ? 1.15 : 0.85)

                    Circle()
                        .fill(extState.accentColor)
                        .frame(width: 9, height: 9)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(extState.label)
                        .font(Wafu12Font.minchoSemiBold(15))
                        .tracking(0.8)
                        .foregroundStyle(Wafu12Palette.textPrimary)

                    Text(extState.detail)
                        .font(Wafu12Font.gothic(12))
                        .foregroundStyle(Wafu12Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)

                Text("切替")
                    .font(Wafu12Font.gothic(10.5, weight: .medium))
                    .tracking(0.6)
                    .foregroundStyle(Wafu12Palette.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.05))
                    .overlay(
                        Capsule()
                            .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.22), lineWidth: 0.75)
                    )
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Wafu12Palette.surfaceCard.opacity(0.88))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(extState.accentColor.opacity(0.32), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("機能拡張の状態を切り替える")
    }

    // MARK: - 3. 手順 4 つ（深紅から黄朽葉への移ろい）

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Capsule()
                    .fill(Wafu12Palette.autumnGradient)
                    .frame(width: 3, height: 15)

                Text("整え方の手順")
                    .font(Wafu12Font.minchoSemiBold(14))
                    .tracking(2.0)
                    .foregroundStyle(Wafu12Palette.textPrimary)

                Spacer(minLength: 0)
            }

            VStack(spacing: 0) {
                ForEach(Wafu12Content.steps) { item in
                    stepRow(item)
                }
            }
        }
    }

    private func stepRow(_ item: Wafu12StepItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    if item.isHighlighted {
                        Circle()
                            .fill(item.dotColor.opacity(0.24))
                            .frame(width: 28, height: 28)
                    }

                    Circle()
                        .fill(item.dotColor)
                        .frame(width: 20, height: 20)

                    Text("\(item.id)")
                        .font(Wafu12Font.gothic(11, weight: .bold))
                        .foregroundStyle(Wafu12Palette.bgDuskBottom)
                }
                .frame(width: 28, height: 28)
                .padding(.top, 12)

                if let nextColor = item.nextDotColor {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [item.dotColor.opacity(0.75), nextColor.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                if item.isHighlighted {
                    HStack(spacing: 5) {
                        Wafu12MapleLeafShape()
                            .fill(Wafu12Palette.ochreLeaf)
                            .frame(width: 11, height: 11)
                        Text("仕上げ")
                            .font(Wafu12Font.gothic(10.5, weight: .semibold))
                            .tracking(1.0)
                            .foregroundStyle(Wafu12Palette.ochreLeaf)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Wafu12Palette.ochreLeaf.opacity(0.14))
                    .clipShape(Capsule())
                    .padding(.bottom, 2)
                }

                Text(item.title)
                    .font(item.isHighlighted ? Wafu12Font.minchoSemiBold(14.5) : Wafu12Font.gothic(13.5, weight: .medium))
                    .foregroundStyle(Wafu12Palette.textPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if let note = item.note {
                    Text(note)
                        .font(Wafu12Font.gothic(11.5))
                        .foregroundStyle(item.isHighlighted ? Wafu12Palette.ochreLeaf.opacity(0.92) : Wafu12Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                item.isHighlighted
                    ? Wafu12Palette.surfaceHighlight.opacity(0.95)
                    : Wafu12Palette.surfaceCard.opacity(0.75)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        item.isHighlighted
                            ? AnyShapeStyle(Wafu12Palette.autumnGradient)
                            : AnyShapeStyle(Wafu12Palette.ochreLeaf.opacity(0.14)),
                        lineWidth: item.isHighlighted ? 1.2 : 0.75
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, item.nextDotColor != nil ? 12 : 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - 4. 注意カード

    private var noticeSection: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Wafu12Palette.ochreLeaf.opacity(0.16))
                    .frame(width: 32, height: 32)
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Wafu12Palette.ochreLeaf)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("サイトごとに許可が要る")
                    .font(Wafu12Font.minchoSemiBold(13.5))
                    .tracking(0.6)
                    .foregroundStyle(Wafu12Palette.textPrimary)

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(Wafu12Font.gothic(12))
                    .foregroundStyle(Wafu12Palette.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(Wafu12Palette.surfaceNotice.opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.28), lineWidth: 0.85)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 5. 主ボタン

    private var primaryActionSection: some View {
        Link(destination: Wafu12Content.safariURL) {
            HStack(spacing: 10) {
                Text("Safari を開く")
                    .font(Wafu12Font.minchoSemiBold(15.5))
                    .tracking(2.2)
                    .foregroundStyle(Wafu12Palette.textPrimary)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Wafu12Palette.textPrimary.opacity(0.88))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Wafu12Palette.buttonGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.45), lineWidth: 0.85)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Wafu12Palette.crimsonDeep.opacity(0.35), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 6. 説明 3 行（夕闇に静かに浮かぶ3句）

    private var featuresSection: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(Wafu12Palette.horizontalFadeRule)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Wafu12Content.features) { feature in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Wafu12Palette.surfaceCard)
                            Circle()
                                .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.28), lineWidth: 0.75)
                            Image(systemName: feature.symbol)
                                .font(.system(size: 13.5, weight: .regular))
                                .foregroundStyle(Wafu12Palette.ochreLeaf)
                        }
                        .frame(width: 34, height: 34)

                        Text(feature.text)
                            .font(Wafu12Font.minchoRegular(13.5))
                            .tracking(0.5)
                            .foregroundStyle(Wafu12Palette.textPrimary.opacity(0.92))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 4)

            Rectangle()
                .fill(Wafu12Palette.horizontalFadeRule)
                .frame(height: 1)
        }
    }

    // MARK: - 7. 足元

    private var footerSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Wafu12Palette.ochreLeaf.opacity(0.0), Wafu12Palette.ochreLeaf.opacity(0.38)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 48, height: 0.75)

                Wafu12MapleLeafShape()
                    .fill(Wafu12Palette.autumnGradient)
                    .frame(width: 14, height: 14)
                    .opacity(0.75)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Wafu12Palette.ochreLeaf.opacity(0.38), Wafu12Palette.ochreLeaf.opacity(0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 48, height: 0.75)
            }

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(Wafu12Font.minchoRegular(11))
                .tracking(1.0)
                .foregroundStyle(Wafu12Palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 2)
    }
}

// MARK: - Shapes & Background

private struct Wafu12MapleLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * w, y: rect.minY + y * h)
        }

        var path = Path()
        // 葉柄から反時計回り（右側から頂点・左側へ）
        path.move(to: pt(0.50, 0.96))
        path.addLine(to: pt(0.515, 0.72))

        // 右下裂片
        path.addQuadCurve(to: pt(0.84, 0.73), control: pt(0.68, 0.78))
        path.addQuadCurve(to: pt(0.66, 0.59), control: pt(0.76, 0.63))

        // 右中裂片
        path.addQuadCurve(to: pt(0.95, 0.43), control: pt(0.83, 0.55))
        path.addQuadCurve(to: pt(0.64, 0.42), control: pt(0.79, 0.37))

        // 中央主裂片
        path.addQuadCurve(to: pt(0.50, 0.05), control: pt(0.62, 0.22))
        path.addQuadCurve(to: pt(0.36, 0.42), control: pt(0.38, 0.22))

        // 左中裂片
        path.addQuadCurve(to: pt(0.05, 0.43), control: pt(0.21, 0.37))
        path.addQuadCurve(to: pt(0.34, 0.59), control: pt(0.17, 0.55))

        // 左下裂片
        path.addQuadCurve(to: pt(0.16, 0.73), control: pt(0.24, 0.63))
        path.addQuadCurve(to: pt(0.485, 0.72), control: pt(0.32, 0.78))

        path.addLine(to: pt(0.50, 0.96))
        path.closeSubpath()
        return path
    }
}

private struct Wafu12DuskBackground: View {
    let isBreathing: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Wafu12Palette.bgDuskTop,
                    Wafu12Palette.bgDuskMid,
                    Wafu12Palette.bgDuskBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 夕暮れの霞（深紅から黄朽葉への静かな滲み）
            GeometryReader { geo in
                ZStack {
                    RadialGradient(
                        colors: [
                            Wafu12Palette.crimsonDeep.opacity(isBreathing ? 0.32 : 0.22),
                            Wafu12Palette.persimmonGlow.opacity(isBreathing ? 0.14 : 0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: geo.size.width * 0.72
                    )
                    .frame(width: geo.size.width * 1.3, height: geo.size.width * 1.1)
                    .position(x: geo.size.width * 0.52, y: 80)

                    RadialGradient(
                        colors: [
                            Wafu12Palette.ochreLeaf.opacity(isBreathing ? 0.13 : 0.07),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: geo.size.width * 0.55
                    )
                    .frame(width: geo.size.width, height: geo.size.width)
                    .position(x: geo.size.width * 0.85, y: 190)

                    // 控えめな落ち葉（画面全体でわずか3枚のみ）
                    Wafu12MapleLeafShape()
                        .fill(Wafu12Palette.autumnGradient)
                        .frame(width: 58, height: 58)
                        .rotationEffect(.degrees(-26))
                        .opacity(0.15)
                        .position(x: geo.size.width - 34, y: 86)

                    Wafu12MapleLeafShape()
                        .fill(Wafu12Palette.ochreLeaf)
                        .frame(width: 28, height: 28)
                        .rotationEffect(.degrees(34))
                        .opacity(0.09)
                        .position(x: 42, y: 158)

                    Wafu12MapleLeafShape()
                        .fill(Wafu12Palette.persimmonGlow)
                        .frame(width: 38, height: 38)
                        .rotationEffect(.degrees(18))
                        .opacity(0.08)
                        .position(x: geo.size.width - 26, y: geo.size.height * 0.62)
                }
            }
        }
    }
}

private struct Wafu12AppMark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Wafu12Palette.crimsonDeep.opacity(0.55),
                            Wafu12Palette.surfaceCard
                        ],
                        center: .top,
                        startRadius: 4,
                        endRadius: 42
                    )
                )

            Circle()
                .strokeBorder(Wafu12Palette.autumnGradient, lineWidth: 1.25)

            Circle()
                .strokeBorder(Wafu12Palette.ochreLeaf.opacity(0.24), lineWidth: 0.6)
                .padding(5)

            Canvas { context, size in
                let w = size.width
                let h = size.height
                let cx = w / 2

                // 柔らかな見開きの頁
                var leftPage = Path()
                leftPage.move(to: CGPoint(x: cx - 1, y: h * 0.44))
                leftPage.addQuadCurve(
                    to: CGPoint(x: w * 0.24, y: h * 0.41),
                    control: CGPoint(x: w * 0.36, y: h * 0.38)
                )
                leftPage.addLine(to: CGPoint(x: w * 0.24, y: h * 0.69))
                leftPage.addQuadCurve(
                    to: CGPoint(x: cx - 1, y: h * 0.72),
                    control: CGPoint(x: w * 0.36, y: h * 0.66)
                )
                leftPage.closeSubpath()

                var rightPage = Path()
                rightPage.move(to: CGPoint(x: cx + 1, y: h * 0.44))
                rightPage.addQuadCurve(
                    to: CGPoint(x: w * 0.76, y: h * 0.41),
                    control: CGPoint(x: w * 0.64, y: h * 0.38)
                )
                rightPage.addLine(to: CGPoint(x: w * 0.76, y: h * 0.69))
                rightPage.addQuadCurve(
                    to: CGPoint(x: cx + 1, y: h * 0.72),
                    control: CGPoint(x: w * 0.64, y: h * 0.66)
                )
                rightPage.closeSubpath()

                context.fill(leftPage, with: .color(Wafu12Palette.textPrimary.opacity(0.94)))
                context.fill(rightPage, with: .color(Wafu12Palette.textPrimary.opacity(0.86)))

                var spine = Path()
                spine.move(to: CGPoint(x: cx, y: h * 0.43))
                spine.addLine(to: CGPoint(x: cx, y: h * 0.73))
                context.stroke(
                    spine,
                    with: .color(Wafu12Palette.ochreLeaf.opacity(0.75)),
                    style: StrokeStyle(lineWidth: 1.0, lineCap: .round)
                )
            }

            // 本の上にそっと舞う小さな紅葉ひとひら
            Wafu12MapleLeafShape()
                .fill(Wafu12Palette.autumnGradient)
                .frame(width: 17, height: 17)
                .offset(y: -15)
        }
    }
}

#Preview {
    Wafu12Screen()
}
