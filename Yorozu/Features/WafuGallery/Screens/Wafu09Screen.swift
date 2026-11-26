import SwiftUI

// MARK: - Wafu 09: 侘び寂び・茶室 (Wabi-Sabi Tea Room)
// 土壁と焼き物の色、手びねりの不揃いな角、静けさで構成する「よみび」設定ガイド画面

enum Wafu09ExtState: CaseIterable {
    case on
    case off
    case checking

    var next: Wafu09ExtState {
        switch self {
        case .on: return .off
        case .off: return .checking
        case .checking: return .on
        }
    }

    var badgeText: String {
        switch self {
        case .on: return "稼働中"
        case .off: return "停止中"
        case .checking: return "確認中"
        }
    }

    var title: String {
        switch self {
        case .on: return "拡張はオンです"
        case .off: return "拡張はオフです"
        case .checking: return "状態を確認しています"
        }
    }

    var detail: String {
        switch self {
        case .on: return "Safari で記事の本文を整えられます"
        case .off: return "設定アプリから「よみび」をオンにしてください"
        case .checking: return "Safari との連携を確かめています"
        }
    }

    var glazeColor: Color {
        switch self {
        case .on: return Wafu09Palette.oribeMoss
        case .off: return Wafu09Palette.akaraku
        case .checking: return Wafu09Palette.kintsugiDeep
        }
    }
}

private enum Wafu09Palette {
    /// 聚楽土（じゅらくつち）— 乾いた土壁の背景
    static let jurakuWall = Color(wafu09Hex: 0xE9E3D7)
    /// 白練（しろねり）— 志野焼の白釉のような器面
    static let shironeri = Color(wafu09Hex: 0xF3EFE6)
    /// 灰釉（はいゆう）— 陰影のある控えめな土灰
    static let haiyu = Color(wafu09Hex: 0xDED6C6)
    /// 黒楽（くろらく）— 焼き物の深い墨茶黒
    static let kuroraku = Color(wafu09Hex: 0x262320)
    /// 鉄釉（てつゆう）— 強調手順に使う濃い茶黒の釉薬
    static let tetsuyu = Color(wafu09Hex: 0x312B26)
    /// 煤竹（すすだけ）— 燻した竹の落ち着いた茶灰
    static let susudake = Color(wafu09Hex: 0x665E54)
    /// 朽葉（くちば）— 土壁に馴染む細い輪郭線
    static let kuchiba = Color(wafu09Hex: 0xB8AC99)
    /// 織部苔（おりべごけ）— オン状態の釉薬点
    static let oribeMoss = Color(wafu09Hex: 0x4F624C)
    /// 深織部（ふかおりべ）— 主ボタンの静かな深緑
    static let deepOribe = Color(wafu09Hex: 0x3E503C)
    /// 赤楽（あからく）— オフ状態・注意の縦線・落款
    static let akaraku = Color(wafu09Hex: 0x9B513E)
    /// 金継ぎ（きんつぎ）— 暗い鉄釉の上で淡く光る古金
    static let kintsugi = Color(wafu09Hex: 0xC6A664)
    /// 古金深（こきんぶか）— 明るい土壁上の確認中ドット
    static let kintsugiDeep = Color(wafu09Hex: 0xA88846)
    /// 障子光（しょうじひかり）— 上から差す柔らかな光
    static let shojiLight = Color(wafu09Hex: 0xFBF8F0)
}

private extension Color {
    init(wafu09Hex hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum Wafu09Fonts {
    static func mincho(_ size: CGFloat, bold: Bool = false) -> Font {
        Font.custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size)
    }

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}

// MARK: - 手びねりの不揃いな角を持つ器のシェイプ

private struct Wafu09PotteryShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomRight: CGFloat
    var bottomLeft: CGFloat
    var sway: CGFloat = 1.0

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let tl = min(topLeft, min(w, h) * 0.45)
        let tr = min(topRight, min(w, h) * 0.45)
        let br = min(bottomRight, min(w, h) * 0.45)
        let bl = min(bottomLeft, min(w, h) * 0.45)

        var path = Path()
        // 上辺（わずかに手仕事のたわみ）
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - tr, y: rect.minY + sway * 0.35),
            control: CGPoint(x: rect.midX, y: rect.minY - sway * 0.5)
        )
        // 右上角
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + tr),
            control: CGPoint(x: rect.maxX - sway * 0.2, y: rect.minY + sway * 0.2)
        )
        // 右辺
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - sway * 0.35, y: rect.maxY - br),
            control: CGPoint(x: rect.maxX + sway * 0.45, y: rect.midY)
        )
        // 右下角
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - br, y: rect.maxY),
            control: CGPoint(x: rect.maxX - sway * 0.2, y: rect.maxY - sway * 0.2)
        )
        // 下辺
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + bl, y: rect.maxY - sway * 0.3),
            control: CGPoint(x: rect.midX, y: rect.maxY + sway * 0.55)
        )
        // 左下角
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bl),
            control: CGPoint(x: rect.minX + sway * 0.2, y: rect.maxY - sway * 0.2)
        )
        // 左辺
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + sway * 0.3, y: rect.minY + tl),
            control: CGPoint(x: rect.minX - sway * 0.45, y: rect.midY)
        )
        // 左上角
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + tl, y: rect.minY),
            control: CGPoint(x: rect.minX + sway * 0.2, y: rect.minY + sway * 0.2)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - 土壁と障子光の背景

private struct Wafu09PlasterBackground: View {
    let lightDrift: Bool

    var body: some View {
        ZStack {
            Wafu09Palette.jurakuWall

            // 障子越しに差し込む柔らかな自然光（静かに揺らぐ）
            RadialGradient(
                colors: [
                    Wafu09Palette.shojiLight.opacity(0.62),
                    Wafu09Palette.shojiLight.opacity(0.18),
                    Color.clear
                ],
                center: UnitPoint(x: lightDrift ? 0.22 : 0.16, y: lightDrift ? 0.08 : 0.05),
                startRadius: 12,
                endRadius: 340
            )

            // 下部のほのかな陰影（床の間の奥行き）
            LinearGradient(
                colors: [
                    Color.clear,
                    Wafu09Palette.kuroraku.opacity(0.045)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            // 土壁の砂粒と藁すさ（決定論的な描画）
            Canvas { context, size in
                var seed: UInt64 = 90421
                func nextRand() -> CGFloat {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return CGFloat((seed >> 33) & 0xFFFF) / 65535.0
                }

                // 微細な土粒子
                let grainCount = 460
                for i in 0..<grainCount {
                    let x = nextRand() * size.width
                    let y = nextRand() * size.height
                    let radius = 0.45 + nextRand() * 1.1
                    let isLight = (i % 5 == 0)
                    let opacity: Double = isLight ? 0.16 : Double(0.025 + nextRand() * 0.05)
                    let rect = CGRect(x: x, y: y, width: radius, height: radius)
                    let fillColor = isLight
                        ? Wafu09Palette.shojiLight.opacity(opacity)
                        : Wafu09Palette.kuroraku.opacity(opacity)
                    context.fill(Path(ellipseIn: rect), with: .color(fillColor))
                }

                // 聚楽壁の藁すさ（ごく細い短い繊維）
                let strawCount = 34
                for _ in 0..<strawCount {
                    let sx = nextRand() * size.width
                    let sy = nextRand() * size.height
                    let length = 7.0 + nextRand() * 14.0
                    let angle = Double(nextRand() - 0.5) * 1.4
                    let ex = sx + CGFloat(cos(angle)) * length
                    let ey = sy + CGFloat(sin(angle)) * length
                    let cx = (sx + ex) * 0.5
                    let cy = (sy + ey) * 0.5 - (nextRand() - 0.5) * 3.0

                    var straw = Path()
                    straw.move(to: CGPoint(x: sx, y: sy))
                    straw.addQuadCurve(to: CGPoint(x: ex, y: ey), control: CGPoint(x: cx, y: cy))
                    context.stroke(
                        straw,
                        with: .color(Wafu09Palette.susudake.opacity(0.09)),
                        style: StrokeStyle(lineWidth: 0.7, lineCap: .round)
                    )
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - アプリのマーク（茶碗の口縁と開いた本、一筋の金継ぎ）

private struct Wafu09TeaBowlMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w * 0.5
            let cy = h * 0.5

            // わずかに不揃いな手びねりの円（器の地）
            var bowl = Path()
            bowl.move(to: CGPoint(x: cx, y: h * 0.07))
            bowl.addCurve(
                to: CGPoint(x: w * 0.93, y: cy + h * 0.02),
                control1: CGPoint(x: w * 0.79, y: h * 0.06),
                control2: CGPoint(x: w * 0.95, y: h * 0.26)
            )
            bowl.addCurve(
                to: CGPoint(x: cx - w * 0.02, y: h * 0.93),
                control1: CGPoint(x: w * 0.91, y: h * 0.78),
                control2: CGPoint(x: w * 0.75, y: h * 0.94)
            )
            bowl.addCurve(
                to: CGPoint(x: w * 0.07, y: cy - h * 0.01),
                control1: CGPoint(x: w * 0.22, y: h * 0.92),
                control2: CGPoint(x: w * 0.06, y: h * 0.75)
            )
            bowl.addCurve(
                to: CGPoint(x: cx, y: h * 0.07),
                control1: CGPoint(x: w * 0.08, y: h * 0.22),
                control2: CGPoint(x: w * 0.24, y: h * 0.08)
            )
            bowl.closeSubpath()

            context.fill(bowl, with: .color(Wafu09Palette.tetsuyu))
            context.stroke(
                bowl,
                with: .color(Wafu09Palette.kuchiba.opacity(0.6)),
                style: StrokeStyle(lineWidth: 1.0)
            )

            // 見開きの本を思わせる静かな二葉の曲線
            var leftPage = Path()
            leftPage.move(to: CGPoint(x: cx, y: h * 0.64))
            leftPage.addQuadCurve(
                to: CGPoint(x: w * 0.28, y: h * 0.42),
                control: CGPoint(x: w * 0.36, y: h * 0.61)
            )
            leftPage.addQuadCurve(
                to: CGPoint(x: cx, y: h * 0.47),
                control: CGPoint(x: w * 0.38, y: h * 0.37)
            )

            var rightPage = Path()
            rightPage.move(to: CGPoint(x: cx, y: h * 0.64))
            rightPage.addQuadCurve(
                to: CGPoint(x: w * 0.72, y: h * 0.42),
                control: CGPoint(x: w * 0.64, y: h * 0.61)
            )
            rightPage.addQuadCurve(
                to: CGPoint(x: cx, y: h * 0.47),
                control: CGPoint(x: w * 0.62, y: h * 0.37)
            )

            let strokeStyle = StrokeStyle(lineWidth: 1.35, lineCap: .round, lineJoin: .round)
            context.stroke(leftPage, with: .color(Wafu09Palette.shironeri), style: strokeStyle)
            context.stroke(rightPage, with: .color(Wafu09Palette.shironeri), style: strokeStyle)

            // 綴じ目の細い縦線
            var spine = Path()
            spine.move(to: CGPoint(x: cx, y: h * 0.47))
            spine.addLine(to: CGPoint(x: cx, y: h * 0.66))
            context.stroke(
                spine,
                with: .color(Wafu09Palette.shironeri.opacity(0.75)),
                style: StrokeStyle(lineWidth: 1.0, lineCap: .round)
            )

            // 右上へ抜ける一筋の金継ぎ
            var kintsugi = Path()
            kintsugi.move(to: CGPoint(x: w * 0.66, y: h * 0.26))
            kintsugi.addLine(to: CGPoint(x: w * 0.76, y: h * 0.21))
            kintsugi.addLine(to: CGPoint(x: w * 0.84, y: h * 0.14))
            context.stroke(
                kintsugi,
                with: .color(Wafu09Palette.kintsugi),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 58, height: 58)
        .accessibilityHidden(true)
    }
}

// MARK: - 強調手順に走る控えめな金継ぎの継ぎ目

private struct Wafu09KintsugiOverlay: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            var mainCrack = Path()
            mainCrack.move(to: CGPoint(x: w * 0.77, y: 0))
            mainCrack.addLine(to: CGPoint(x: w * 0.74, y: h * 0.28))
            mainCrack.addLine(to: CGPoint(x: w * 0.81, y: h * 0.56))
            mainCrack.addLine(to: CGPoint(x: w * 0.78, y: h * 0.82))
            mainCrack.addLine(to: CGPoint(x: w * 0.83, y: h))

            var branchCrack = Path()
            branchCrack.move(to: CGPoint(x: w * 0.74, y: h * 0.28))
            branchCrack.addLine(to: CGPoint(x: w * 0.66, y: h * 0.36))

            // わずかな金の滲み
            context.stroke(
                mainCrack,
                with: .color(Wafu09Palette.kintsugi.opacity(0.22)),
                style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round)
            )
            // 本筋の金継ぎ線
            context.stroke(
                mainCrack,
                with: .color(Wafu09Palette.kintsugi.opacity(0.75)),
                style: StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round)
            )
            context.stroke(
                branchCrack,
                with: .color(Wafu09Palette.kintsugi.opacity(0.55)),
                style: StrokeStyle(lineWidth: 0.9, lineCap: .round, lineJoin: .round)
            )
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 説明3行用の極細アイコン（SwiftUI独自PathでHTMLと完全一致）

private enum Wafu09FeatureKind {
    case minchoBook
    case spacingLines
    case bookmark
}

private struct Wafu09FeatureGlyph: View {
    let kind: Wafu09FeatureKind

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let stroke = StrokeStyle(lineWidth: 1.25, lineCap: .round, lineJoin: .round)
            let ink = Wafu09Palette.kuroraku.opacity(0.82)

            switch kind {
            case .minchoBook:
                var path = Path()
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.24))
                path.addQuadCurve(to: CGPoint(x: w * 0.14, y: h * 0.18), control: CGPoint(x: w * 0.32, y: h * 0.16))
                path.addLine(to: CGPoint(x: w * 0.14, y: h * 0.78))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.84), control: CGPoint(x: w * 0.32, y: h * 0.76))
                path.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.78), control: CGPoint(x: w * 0.68, y: h * 0.76))
                path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.18))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.24), control: CGPoint(x: w * 0.68, y: h * 0.16))
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.24))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.84))
                context.stroke(path, with: .color(ink), style: stroke)

            case .spacingLines:
                var path = Path()
                path.move(to: CGPoint(x: w * 0.16, y: h * 0.26))
                path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.26))
                path.move(to: CGPoint(x: w * 0.16, y: h * 0.50))
                path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.50))
                path.move(to: CGPoint(x: w * 0.16, y: h * 0.74))
                path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.74))
                context.stroke(path, with: .color(ink), style: stroke)

            case .bookmark:
                var path = Path()
                path.move(to: CGPoint(x: w * 0.28, y: h * 0.16))
                path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.16))
                path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.84))
                path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.67))
                path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.84))
                path.closeSubpath()
                context.stroke(path, with: .color(ink), style: stroke)
            }
        }
        .frame(width: 20, height: 20)
        .accessibilityHidden(true)
    }
}

// MARK: - 細い筆致の区切り線

private struct Wafu09BrushDivider: View {
    var body: some View {
        Canvas { context, size in
            var line = Path()
            line.move(to: CGPoint(x: 0, y: size.height * 0.5))
            line.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.5 + 0.4),
                control: CGPoint(x: size.width * 0.45, y: size.height * 0.5 - 0.8)
            )
            context.stroke(
                line,
                with: .color(Wafu09Palette.kuchiba.opacity(0.65)),
                style: StrokeStyle(lineWidth: 0.8, lineCap: .round)
            )
        }
        .frame(height: 4)
    }
}

// MARK: - メイン画面

struct Wafu09Screen: View {
    @State private var extState: Wafu09ExtState = .on
    @State private var glazePulse = false
    @State private var lightDrift = false

    private static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        ZStack {
            Wafu09PlasterBackground(lightDrift: lightDrift)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    heroSection
                    statusSection
                    stepsSection
                    noticeSection
                    primaryActionSection
                    featuresSection
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true)) {
                glazePulse = true
            }
            withAnimation(.easeInOut(duration: 11.0).repeatForever(autoreverses: true)) {
                lightDrift = true
            }
        }
    }

    // MARK: 1. ヒーロー

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                Wafu09TeaBowlMark()

                VStack(alignment: .leading, spacing: 6) {
                    Text("よみび")
                        .font(Wafu09Fonts.mincho(30, bold: false))
                        .tracking(5)
                        .foregroundStyle(Wafu09Palette.kuroraku)

                    Text("ウェブの文章を、本のように読む")
                        .font(Wafu09Fonts.mincho(13))
                        .tracking(0.8)
                        .foregroundStyle(Wafu09Palette.susudake)
                        .lineSpacing(4)
                }
                .padding(.top, 2)
            }

            HStack(spacing: 8) {
                potteryTag("v1.0", tl: 9, tr: 5, br: 10, bl: 6)
                potteryTag("iOS 18+", tl: 6, tr: 10, br: 6, bl: 9)
                potteryTag("Safari", tl: 10, tr: 6, br: 8, bl: 5)
            }

            Wafu09BrushDivider()
                .padding(.top, 4)
        }
    }

    private func potteryTag(_ label: String, tl: CGFloat, tr: CGFloat, br: CGFloat, bl: CGFloat) -> some View {
        let shape = Wafu09PotteryShape(topLeft: tl, topRight: tr, bottomRight: br, bottomLeft: bl, sway: 0.5)
        return Text(label)
            .font(Wafu09Fonts.sans(11, weight: .medium))
            .tracking(0.6)
            .foregroundStyle(Wafu09Palette.susudake)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(shape.fill(Wafu09Palette.shironeri.opacity(0.75)))
            .overlay(shape.stroke(Wafu09Palette.kuchiba.opacity(0.7), lineWidth: 0.8))
    }

    // MARK: 2. 状態表示

    private var statusSection: some View {
        let cardShape = Wafu09PotteryShape(topLeft: 16, topRight: 10, bottomRight: 18, bottomLeft: 12, sway: 1.1)

        return Button {
            withAnimation(.easeInOut(duration: 0.28)) {
                extState = extState.next
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                // 釉薬の点（静かな呼吸アニメーション）
                ZStack {
                    Circle()
                        .fill(extState.glazeColor.opacity(glazePulse ? 0.24 : 0.08))
                        .frame(width: 24, height: 24)
                        .scaleEffect(glazePulse ? 1.12 : 0.88)

                    Circle()
                        .fill(extState.glazeColor)
                        .frame(width: 10, height: 10)
                        .opacity(glazePulse ? 1.0 : 0.68)
                }
                .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(extState.title)
                            .font(Wafu09Fonts.mincho(15, bold: true))
                            .tracking(0.6)
                            .foregroundStyle(Wafu09Palette.kuroraku)

                        Text(extState.badgeText)
                            .font(Wafu09Fonts.sans(10, weight: .medium))
                            .tracking(0.5)
                            .foregroundStyle(extState.glazeColor)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                Wafu09PotteryShape(topLeft: 6, topRight: 4, bottomRight: 7, bottomLeft: 4, sway: 0.3)
                                    .fill(extState.glazeColor.opacity(0.11))
                            )
                    }

                    Text(extState.detail)
                        .font(Wafu09Fonts.sans(12))
                        .foregroundStyle(Wafu09Palette.susudake)
                        .lineSpacing(3)
                }

                Spacer(minLength: 4)

                Text("切替")
                    .font(Wafu09Fonts.mincho(11))
                    .foregroundStyle(Wafu09Palette.susudake.opacity(0.75))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(cardShape.fill(Wafu09Palette.shironeri))
            .overlay(cardShape.stroke(Wafu09Palette.kuchiba.opacity(0.75), lineWidth: 0.9))
            .shadow(color: Wafu09Palette.kuroraku.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("機能拡張の状態、\(extState.title)。タップして切り替え")
    }

    // MARK: 3. 手順 4 つ

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("はじめの設え")
                    .font(Wafu09Fonts.mincho(14, bold: true))
                    .tracking(2.2)
                    .foregroundStyle(Wafu09Palette.kuroraku)

                Spacer()

                Text("一 — 四")
                    .font(Wafu09Fonts.mincho(11))
                    .tracking(1.5)
                    .foregroundStyle(Wafu09Palette.susudake)
            }
            .padding(.horizontal, 2)

            VStack(spacing: 11) {
                stepRow(
                    kanji: "一",
                    text: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
                    note: "設定アプリのいちばん下のほう",
                    corners: (14, 9, 13, 10)
                )
                stepRow(
                    kanji: "二",
                    text: "「よみび」をオンにする",
                    note: nil,
                    corners: (10, 15, 11, 13)
                )
                stepRow(
                    kanji: "三",
                    text: "Safari で好きな記事を開く",
                    note: nil,
                    corners: (13, 10, 15, 9)
                )
                highlightedStepFour
            }
        }
    }

    private func stepRow(
        kanji: String,
        text: String,
        note: String?,
        corners: (CGFloat, CGFloat, CGFloat, CGFloat)
    ) -> some View {
        let shape = Wafu09PotteryShape(
            topLeft: corners.0,
            topRight: corners.1,
            bottomRight: corners.2,
            bottomLeft: corners.3,
            sway: 0.85
        )
        let numShape = Wafu09PotteryShape(topLeft: 8, topRight: 5, bottomRight: 9, bottomLeft: 6, sway: 0.4)

        return HStack(alignment: .top, spacing: 13) {
            Text(kanji)
                .font(Wafu09Fonts.mincho(13, bold: true))
                .foregroundStyle(Wafu09Palette.susudake)
                .frame(width: 28, height: 28)
                .background(numShape.fill(Wafu09Palette.haiyu.opacity(0.75)))
                .overlay(numShape.stroke(Wafu09Palette.kuchiba.opacity(0.65), lineWidth: 0.7))

            VStack(alignment: .leading, spacing: 5) {
                Text(text)
                    .font(Wafu09Fonts.mincho(14))
                    .foregroundStyle(Wafu09Palette.kuroraku)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if let note {
                    Text(note)
                        .font(Wafu09Fonts.sans(11.5))
                        .foregroundStyle(Wafu09Palette.susudake)
                        .lineSpacing(3)
                }
            }
            .padding(.top, 3)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(shape.fill(Wafu09Palette.shironeri.opacity(0.78)))
        .overlay(shape.stroke(Wafu09Palette.kuchiba.opacity(0.6), lineWidth: 0.8))
    }

    /// 手順 4（強調）: 鉄釉の深い器に一筋の金継ぎが走る要の手順
    private var highlightedStepFour: some View {
        let shape = Wafu09PotteryShape(topLeft: 17, topRight: 11, bottomRight: 19, bottomLeft: 12, sway: 1.2)
        let numShape = Wafu09PotteryShape(topLeft: 9, topRight: 6, bottomRight: 10, bottomLeft: 6, sway: 0.4)

        return HStack(alignment: .top, spacing: 13) {
            Text("四")
                .font(Wafu09Fonts.mincho(13, bold: true))
                .foregroundStyle(Wafu09Palette.tetsuyu)
                .frame(width: 28, height: 28)
                .background(numShape.fill(Wafu09Palette.kintsugi))

            VStack(alignment: .leading, spacing: 6) {
                Text("要の手順")
                    .font(Wafu09Fonts.sans(10, weight: .medium))
                    .tracking(1.4)
                    .foregroundStyle(Wafu09Palette.kintsugi)

                Text("アドレスバーの「ぁあ」から「よみび」を選ぶ")
                    .font(Wafu09Fonts.mincho(15, bold: true))
                    .foregroundStyle(Wafu09Palette.shironeri)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Text("ここで初めて本文が整う")
                    .font(Wafu09Fonts.mincho(12))
                    .tracking(0.6)
                    .foregroundStyle(Wafu09Palette.kintsugi.opacity(0.95))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 18)
        .background(shape.fill(Wafu09Palette.tetsuyu))
        .overlay(
            Wafu09KintsugiOverlay()
                .clipShape(shape)
        )
        .overlay(shape.stroke(Wafu09Palette.kintsugi.opacity(0.45), lineWidth: 0.9))
        .shadow(color: Wafu09Palette.kuroraku.opacity(0.14), radius: 10, x: 0, y: 5)
    }

    // MARK: 4. 注意カード

    private var noticeSection: some View {
        let shape = Wafu09PotteryShape(topLeft: 11, topRight: 16, bottomRight: 10, bottomLeft: 15, sway: 0.9)

        return HStack(alignment: .top, spacing: 14) {
            // 赤楽の細い土筆線
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Wafu09Palette.akaraku)
                .frame(width: 2.5)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 5) {
                Text("サイトごとに許可が要る")
                    .font(Wafu09Fonts.mincho(13.5, bold: true))
                    .tracking(0.6)
                    .foregroundStyle(Wafu09Palette.kuroraku)

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(Wafu09Fonts.sans(12))
                    .foregroundStyle(Wafu09Palette.susudake)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(shape.fill(Wafu09Palette.haiyu.opacity(0.82)))
        .overlay(shape.stroke(Wafu09Palette.kuchiba.opacity(0.72), lineWidth: 0.8))
    }

    // MARK: 5. 主ボタン

    private var primaryActionSection: some View {
        let shape = Wafu09PotteryShape(topLeft: 15, topRight: 11, bottomRight: 16, bottomLeft: 10, sway: 1.0)

        return Link(destination: Self.safariURL) {
            HStack {
                Spacer()
                Text("Safari を開く")
                    .font(Wafu09Fonts.mincho(15.5, bold: true))
                    .tracking(2.0)
                    .foregroundStyle(Wafu09Palette.shironeri)

                Text("→")
                    .font(Wafu09Fonts.sans(14, weight: .light))
                    .foregroundStyle(Wafu09Palette.shironeri.opacity(0.8))
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(shape.fill(Wafu09Palette.deepOribe))
            .overlay(shape.stroke(Wafu09Palette.kuroraku.opacity(0.22), lineWidth: 0.9))
            .shadow(color: Wafu09Palette.deepOribe.opacity(0.22), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: 6. 説明 3 行

    private var featuresSection: some View {
        let shape = Wafu09PotteryShape(topLeft: 14, topRight: 11, bottomRight: 16, bottomLeft: 12, sway: 0.9)

        return VStack(alignment: .leading, spacing: 0) {
            featureRow(kind: .minchoBook, text: "本文だけを抜き出して明朝体で組む")
            Wafu09BrushDivider()
                .padding(.vertical, 10)
            featureRow(kind: .spacingLines, text: "行間と文字の大きさを端末に合わせる")
            Wafu09BrushDivider()
                .padding(.vertical, 10)
            featureRow(kind: .bookmark, text: "読んだ位置を覚えておく")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(shape.fill(Wafu09Palette.shironeri.opacity(0.72)))
        .overlay(shape.stroke(Wafu09Palette.kuchiba.opacity(0.65), lineWidth: 0.8))
    }

    private func featureRow(kind: Wafu09FeatureKind, text: String) -> some View {
        HStack(spacing: 13) {
            Wafu09FeatureGlyph(kind: kind)

            Text(text)
                .font(Wafu09Fonts.mincho(13))
                .tracking(0.4)
                .foregroundStyle(Wafu09Palette.kuroraku)
                .lineSpacing(3)

            Spacer(minLength: 0)
        }
    }

    // MARK: 7. 足元

    private var footerSection: some View {
        let sealShape = Wafu09PotteryShape(topLeft: 3, topRight: 4, bottomRight: 2.5, bottomLeft: 4, sway: 0.3)

        return VStack(spacing: 14) {
            Wafu09BrushDivider()

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(Wafu09Fonts.mincho(11.5))
                .tracking(0.8)
                .foregroundStyle(Wafu09Palette.susudake)
                .multilineTextAlignment(.center)

            // 小さな赤楽の陶印（落款の余韻）
            Text("よ")
                .font(Wafu09Fonts.mincho(9, bold: true))
                .foregroundStyle(Wafu09Palette.shironeri)
                .frame(width: 18, height: 18)
                .background(sealShape.fill(Wafu09Palette.akaraku.opacity(0.86)))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
}

#Preview {
    Wafu09Screen()
}
