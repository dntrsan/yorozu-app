import SwiftUI

// MARK: - Wafu 10: 縦書きの古書 (Vertical Classical Japanese Book)
// 和綴じ（四つ目綴じ）・四周双辺・縦書きの本文と手順・ルビと割注の遊びで構成する「よみび」設定ガイド画面

enum Wafu10ExtState: CaseIterable {
    case on
    case off
    case checking

    var next: Wafu10ExtState {
        switch self {
        case .on: return .off
        case .off: return .checking
        case .checking: return .on
        }
    }

    var sealText: String {
        switch self {
        case .on: return "有効"
        case .off: return "停止"
        case .checking: return "確認"
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
        case .on: return "Safari にて本文を明朝体へ整えられます"
        case .off: return "設定アプリより「よみび」を有効にしてください"
        case .checking: return "Safari との連携を確かめております"
        }
    }

    var sealColor: Color {
        switch self {
        case .on: return Wafu10Palette.matsuba
        case .off: return Wafu10Palette.honshu
        case .checking: return Wafu10Palette.asagiThread
        }
    }
}

private enum Wafu10Palette {
    /// 古楮紙（ここうぞし）— 歳月を経て温かく焼けた和紙
    static let oldWashi = Color(wafu10Hex: 0xF4EBD6)
    /// 鳥の子（とりのこ）— 題簽や枠内に使うわずかに明るい和紙
    static let torinoko = Color(wafu10Hex: 0xFAF4E5)
    /// 紙焼（かみやけ）— ページの縁に漂うごく淡い経年影
    static let paperEdge = Color(wafu10Hex: 0xDECBA8)
    /// 藍表紙（あいびょうし）— 和綴じ本の背と主ボタンの深藍
    static let aiCover = Color(wafu10Hex: 0x263E57)
    /// 浅葱糸（あさぎいと）— 確認中印・控えめな藍
    static let asagiThread = Color(wafu10Hex: 0x4A6580)
    /// 濃墨（こずみ）— 木版・活版の凛とした本文墨
    static let kozumi = Color(wafu10Hex: 0x1E1B18)
    /// 薄墨（うすずみ）— ルビ・割注・副文の落ち着いた墨
    static let usuzumi = Color(wafu10Hex: 0x5C5246)
    /// 界線茶（かいせんちゃ）— 縦罫線・細い区切り
    static let keisen = Color(wafu10Hex: 0xC2B294)
    /// 本朱（ほんしゅ）— 強調手順の朱書き・傍点・蔵書印・栞紐
    static let honshu = Color(wafu10Hex: 0xB53528)
    /// 淡朱（うすしゅ）— 強調手順のわずかな朱敷き
    static let usushu = Color(wafu10Hex: 0xEFE0D2)
    /// 松葉（まつば）— 拡張オン状態の落ち着いた深緑印
    static let matsuba = Color(wafu10Hex: 0x375C44)
    /// 綴じ糸白（とじいとしろ）— 四つ目綴じの生成り糸
    static let bindingThread = Color(wafu10Hex: 0xEDE4CE)
}

private extension Color {
    init(wafu10Hex hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum Wafu10Fonts {
    static func mincho(_ size: CGFloat, bold: Bool = false) -> Font {
        Font.custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size)
    }

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}

// MARK: - 縦書きトークンと縦組みエンジン（ルビ・傍点・約物・割注対応）

private enum Wafu10VerticalToken: Identifiable {
    case plain(String)
    case ruby(base: String, reading: String, rubyColor: Color? = nil)
    case bouten(String, dotColor: Color)
    case latin(String, height: CGFloat)
    case warichu(rightLine: String, leftLine: String, color: Color)

    var id: String {
        switch self {
        case .plain(let s): return "p:\(s)"
        case .ruby(let b, let r, _): return "r:\(b):\(r)"
        case .bouten(let s, _): return "b:\(s)"
        case .latin(let s, _): return "l:\(s)"
        case .warichu(let r, let l, _): return "w:\(r):\(l)"
        }
    }
}

private struct Wafu10VerticalGlyphInfo {
    let text: String
    let rotate90: Bool
    let xOffset: CGFloat
    let yOffset: CGFloat
}

private func wafu10GlyphInfo(for ch: Character, fontSize: CGFloat) -> Wafu10VerticalGlyphInfo {
    switch ch {
    case "「":
        return Wafu10VerticalGlyphInfo(text: "﹁", rotate90: false, xOffset: 0, yOffset: 0)
    case "」":
        return Wafu10VerticalGlyphInfo(text: "﹂", rotate90: false, xOffset: 0, yOffset: 0)
    case "（":
        return Wafu10VerticalGlyphInfo(text: "︵", rotate90: false, xOffset: 0, yOffset: 0)
    case "）":
        return Wafu10VerticalGlyphInfo(text: "︶", rotate90: false, xOffset: 0, yOffset: 0)
    case "→", "ー":
        return Wafu10VerticalGlyphInfo(text: String(ch), rotate90: true, xOffset: 0, yOffset: 0)
    case "、", "。":
        return Wafu10VerticalGlyphInfo(text: String(ch), rotate90: false, xOffset: fontSize * 0.34, yOffset: -fontSize * 0.24)
    case "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "っ":
        return Wafu10VerticalGlyphInfo(text: String(ch), rotate90: false, xOffset: fontSize * 0.08, yOffset: -fontSize * 0.05)
    default:
        return Wafu10VerticalGlyphInfo(text: String(ch), rotate90: false, xOffset: 0, yOffset: 0)
    }
}

/// 1 行分の縦書きを描画するコンポーネント（ルビ・傍点・縦回転欧文・割注に対応）
private struct Wafu10VerticalLine: View {
    let tokens: [Wafu10VerticalToken]
    var fontSize: CGFloat = 13.5
    var bold: Bool = false
    var color: Color = Wafu10Palette.kozumi
    var charSpacing: CGFloat = 1.5

    var body: some View {
        VStack(alignment: .center, spacing: charSpacing) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                tokenView(token)
            }
        }
    }

    @ViewBuilder
    private func tokenView(_ token: Wafu10VerticalToken) -> some View {
        switch token {
        case .plain(let text):
            verticalChars(text, color: color)

        case .ruby(let base, let reading, let rubyColor):
            // 縦書きルビ：親文字の縦芯を崩さず右側に極小文字を添える
            let rubySize = max(7.0, fontSize * 0.46)
            verticalChars(base, color: color)
                .overlay(alignment: .trailing) {
                    VStack(spacing: 0.5) {
                        ForEach(Array(reading.enumerated()), id: \.offset) { _, rch in
                            Text(String(rch))
                                .font(Wafu10Fonts.mincho(rubySize))
                                .foregroundStyle(rubyColor ?? Wafu10Palette.usuzumi)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .offset(x: rubySize + 2.5)
                }

        case .bouten(let text, let dotColor):
            // 傍点（圏点）：親文字の縦芯を崩さず右側に朱点を打つ
            VStack(spacing: charSpacing) {
                ForEach(Array(text.enumerated()), id: \.offset) { _, ch in
                    singleChar(ch, color: color)
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(dotColor)
                                .frame(width: 2.8, height: 2.8)
                                .offset(x: 4.5)
                        }
                }
            }

        case .latin(let word, let height):
            Text(word)
                .font(Wafu10Fonts.mincho(fontSize * 0.92, bold: bold))
                .foregroundStyle(color)
                .fixedSize()
                .rotationEffect(.degrees(90))
                .frame(width: fontSize * 1.15, height: height)

        case .warichu(let rightLine, let leftLine, let warichuColor):
            // 割注（双行小文字注釈）：右行 → 左行の順で 1 行幅に割り込む
            VStack(spacing: 1) {
                Text("︵")
                    .font(Wafu10Fonts.mincho(8.5))
                    .foregroundStyle(warichuColor.opacity(0.75))

                HStack(alignment: .top, spacing: 1.5) {
                    warichuMiniColumn(leftLine, color: warichuColor)
                    warichuMiniColumn(rightLine, color: warichuColor)
                }

                Text("︶")
                    .font(Wafu10Fonts.mincho(8.5))
                    .foregroundStyle(warichuColor.opacity(0.75))
            }
            .padding(.top, 2)
        }
    }

    private func verticalChars(_ text: String, color: Color) -> some View {
        VStack(spacing: charSpacing) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, ch in
                singleChar(ch, color: color)
            }
        }
    }

    private func singleChar(_ ch: Character, color: Color) -> some View {
        let info = wafu10GlyphInfo(for: ch, fontSize: fontSize)
        return Text(info.text)
            .font(Wafu10Fonts.mincho(fontSize, bold: bold))
            .foregroundStyle(color)
            .frame(width: fontSize * 1.12, height: fontSize * 1.08)
            .rotationEffect(.degrees(info.rotate90 ? 90 : 0))
            .offset(x: info.xOffset, y: info.yOffset)
    }

    private func warichuMiniColumn(_ text: String, color: Color) -> some View {
        VStack(spacing: 0.5) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, ch in
                let info = wafu10GlyphInfo(for: ch, fontSize: 8.8)
                Text(info.text)
                    .font(Wafu10Fonts.mincho(8.8))
                    .foregroundStyle(color)
                    .frame(width: 9.5, height: 9.6)
                    .rotationEffect(.degrees(info.rotate90 ? 90 : 0))
                    .offset(x: info.xOffset, y: info.yOffset)
            }
        }
    }
}

// MARK: - 古和紙テクスチャ背景

private struct Wafu10WashiBackground: View {
    var body: some View {
        ZStack {
            Wafu10Palette.oldWashi

            // 紙の周囲にほんのりとした古書の紙焼け
            RadialGradient(
                colors: [
                    Wafu10Palette.torinoko.opacity(0.55),
                    Color.clear,
                    Wafu10Palette.paperEdge.opacity(0.32)
                ],
                center: .center,
                startRadius: 40,
                endRadius: 420
            )

            // 楮紙（こうぞし）の繊細な繊維
            Canvas { context, size in
                var seed: UInt64 = 10847
                func nextRand() -> CGFloat {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return CGFloat((seed >> 33) & 0xFFFF) / 65535.0
                }

                // 淡い和紙の斑点
                for i in 0..<240 {
                    let x = nextRand() * size.width
                    let y = nextRand() * size.height
                    let r = 0.6 + nextRand() * 1.3
                    let isWarm = (i % 3 == 0)
                    let color = isWarm
                        ? Wafu10Palette.paperEdge.opacity(0.28)
                        : Wafu10Palette.usuzumi.opacity(0.035)
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)), with: .color(color))
                }

                // 楮の長い繊維
                for _ in 0..<52 {
                    let sx = nextRand() * size.width
                    let sy = nextRand() * size.height
                    let len = 10.0 + nextRand() * 24.0
                    let angle = Double(nextRand() - 0.5) * 3.14
                    let ex = sx + CGFloat(cos(angle)) * len
                    let ey = sy + CGFloat(sin(angle)) * len
                    let cx = (sx + ex) * 0.5 + (nextRand() - 0.5) * 5.0
                    let cy = (sy + ey) * 0.5 + (nextRand() - 0.5) * 5.0

                    var fiber = Path()
                    fiber.move(to: CGPoint(x: sx, y: sy))
                    fiber.addQuadCurve(to: CGPoint(x: ex, y: ey), control: CGPoint(x: cx, y: cy))
                    context.stroke(
                        fiber,
                        with: .color(Wafu10Palette.keisen.opacity(0.22)),
                        style: StrokeStyle(lineWidth: 0.6, lineCap: .round)
                    )
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - 右端の和綴じ（四つ目綴じ）と揺れる栞紐

private struct Wafu10WatojiBinding: View {
    let ribbonSway: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 藍染めの背表紙帯
            HStack(spacing: 0) {
                // 綴じ目の折り溝
                Rectangle()
                    .fill(Wafu10Palette.kozumi.opacity(0.16))
                    .frame(width: 1.5)

                Rectangle()
                    .fill(Wafu10Palette.aiCover)
                    .frame(width: 24)
            }

            // 四つ目綴じの糸（Canvas 描画）
            Canvas { context, size in
                let stitchYRatios: [CGFloat] = [0.14, 0.38, 0.62, 0.86]
                let holeX: CGFloat = 9.0
                let rightEdge = size.width
                let threadStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)

                // 上下の角裂（かどぎれ）風の小さな綴じ
                for ratio in [CGFloat(0.03), CGFloat(0.97)] {
                    let y = size.height * ratio
                    var cap = Path()
                    cap.move(to: CGPoint(x: holeX, y: y))
                    cap.addLine(to: CGPoint(x: rightEdge, y: y))
                    context.stroke(cap, with: .color(Wafu10Palette.bindingThread.opacity(0.75)), style: threadStyle)
                }

                // 縦の連なり糸
                var spineThread = Path()
                spineThread.move(to: CGPoint(x: holeX, y: size.height * 0.03))
                spineThread.addLine(to: CGPoint(x: holeX, y: size.height * 0.97))
                context.stroke(
                    spineThread,
                    with: .color(Wafu10Palette.bindingThread.opacity(0.82)),
                    style: StrokeStyle(lineWidth: 1.15, lineCap: .round)
                )

                // 四つの綴じ穴と横渡り糸
                for ratio in stitchYRatios {
                    let y = size.height * ratio
                    var cross = Path()
                    cross.move(to: CGPoint(x: holeX, y: y))
                    cross.addLine(to: CGPoint(x: rightEdge, y: y))
                    context.stroke(cross, with: .color(Wafu10Palette.bindingThread), style: threadStyle)

                    let knot = CGRect(x: holeX - 2.2, y: y - 2.2, width: 4.4, height: 4.4)
                    context.fill(Path(ellipseIn: knot), with: .color(Wafu10Palette.kozumi.opacity(0.55)))
                    context.stroke(Path(ellipseIn: knot), with: .color(Wafu10Palette.bindingThread), lineWidth: 0.9)
                }
            }
            .frame(width: 25.5)

            // 上端からほのかに揺れる朱色の栞紐（しおりひも）
            Wafu10BookmarkRibbon()
                .frame(width: 10, height: 54)
                .offset(x: -9, y: 0)
                .rotationEffect(.degrees(ribbonSway ? 1.8 : -1.4), anchor: .top)
        }
        .frame(width: 25.5)
        .ignoresSafeArea(edges: .vertical)
        .allowsHitTesting(false)
    }
}

private struct Wafu10BookmarkRibbon: View {
    var body: some View {
        Canvas { context, size in
            var ribbon = Path()
            ribbon.move(to: CGPoint(x: size.width * 0.25, y: 0))
            ribbon.addLine(to: CGPoint(x: size.width * 0.75, y: 0))
            ribbon.addLine(to: CGPoint(x: size.width * 0.75, y: size.height * 0.84))
            ribbon.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.70))
            ribbon.addLine(to: CGPoint(x: size.width * 0.25, y: size.height * 0.84))
            ribbon.closeSubpath()
            context.fill(ribbon, with: .color(Wafu10Palette.honshu.opacity(0.88)))
        }
    }
}

// MARK: - 四周双辺（古書の二重匡郭）フレーム修飾

private struct Wafu10DoubleBorder: ViewModifier {
    var outerColor: Color = Wafu10Palette.kozumi
    var innerColor: Color = Wafu10Palette.kozumi.opacity(0.55)
    var background: Color = Wafu10Palette.torinoko.opacity(0.55)

    func body(content: Content) -> some View {
        content
            .background(background)
            .overlay(
                Rectangle()
                    .stroke(innerColor, lineWidth: 0.6)
                    .padding(3)
            )
            .overlay(
                Rectangle()
                    .stroke(outerColor, lineWidth: 1.5)
            )
    }
}

private extension View {
    func wafu10DoubleBorder(
        outer: Color = Wafu10Palette.kozumi,
        inner: Color = Wafu10Palette.kozumi.opacity(0.55),
        background: Color = Wafu10Palette.torinoko.opacity(0.55)
    ) -> some View {
        modifier(Wafu10DoubleBorder(outerColor: outer, innerColor: inner, background: background))
    }
}

// MARK: - アプリのマーク（和綴じ本と縦罫を象った朱印紋）

private struct Wafu10BookSealMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // 朱印の角枠（わずかに墨だまりのある印影風）
            let outerRect = CGRect(x: 1.5, y: 1.5, width: w - 3, height: h - 3)
            let outerPath = Path(roundedRect: outerRect, cornerRadius: 2.5)
            context.fill(outerPath, with: .color(Wafu10Palette.honshu))

            let innerRect = CGRect(x: 4.5, y: 4.5, width: w - 9, height: h - 9)
            context.stroke(
                Path(roundedRect: innerRect, cornerRadius: 1.2),
                with: .color(Wafu10Palette.torinoko.opacity(0.88)),
                style: StrokeStyle(lineWidth: 0.9)
            )

            // 印の内部：和本の見開きと縦書きの界線 3 本
            var book = Path()
            book.move(to: CGPoint(x: w * 0.25, y: h * 0.26))
            book.addLine(to: CGPoint(x: w * 0.75, y: h * 0.26))
            book.addLine(to: CGPoint(x: w * 0.75, y: h * 0.74))
            book.addLine(to: CGPoint(x: w * 0.25, y: h * 0.74))
            book.closeSubpath()

            // 右綴じの糸点 2 つと縦書き線
            book.move(to: CGPoint(x: w * 0.64, y: h * 0.26))
            book.addLine(to: CGPoint(x: w * 0.64, y: h * 0.74))
            book.move(to: CGPoint(x: w * 0.50, y: h * 0.34))
            book.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            book.move(to: CGPoint(x: w * 0.37, y: h * 0.34))
            book.addLine(to: CGPoint(x: w * 0.37, y: h * 0.58))

            context.stroke(
                book,
                with: .color(Wafu10Palette.torinoko),
                style: StrokeStyle(lineWidth: 1.25, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: 36, height: 36)
        .accessibilityHidden(true)
    }
}

// MARK: - 凡例（説明 3 行）用の木版風極細アイコン

private enum Wafu10FeatureIconKind {
    case verticalType
    case lineMeasure
    case ribbonMark
}

private struct Wafu10WoodblockIcon: View {
    let kind: Wafu10FeatureIconKind

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let stroke = StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round)
            let ink = Wafu10Palette.kozumi

            switch kind {
            case .verticalType:
                // 和本の頁と縦書き 3 行
                var p = Path()
                p.addRect(CGRect(x: w * 0.16, y: h * 0.14, width: w * 0.68, height: h * 0.72))
                p.move(to: CGPoint(x: w * 0.66, y: h * 0.26))
                p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.74))
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.26))
                p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.74))
                p.move(to: CGPoint(x: w * 0.34, y: h * 0.26))
                p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.62))
                context.stroke(p, with: .color(ink), style: stroke)

            case .lineMeasure:
                // 行間と文字寸法を測る尺
                var p = Path()
                p.move(to: CGPoint(x: w * 0.22, y: h * 0.22))
                p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.78))
                p.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
                p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
                p.move(to: CGPoint(x: w * 0.78, y: h * 0.22))
                p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.78))
                p.move(to: CGPoint(x: w * 0.22, y: h * 0.50))
                p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))
                context.stroke(p, with: .color(ink), style: stroke)

            case .ribbonMark:
                // 古書の栞
                var p = Path()
                p.move(to: CGPoint(x: w * 0.30, y: h * 0.15))
                p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.15))
                p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.85))
                p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.68))
                p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.85))
                p.closeSubpath()
                context.stroke(p, with: .color(Wafu10Palette.honshu), style: stroke)
            }
        }
        .frame(width: 20, height: 20)
        .accessibilityHidden(true)
    }
}

// MARK: - メイン画面

struct Wafu10Screen: View {
    @State private var extState: Wafu10ExtState = .on { didSet { WafuHaptics.tap() } }
    @State private var sealPulse = false
    @State private var ribbonSway = false

    private static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        ZStack(alignment: .trailing) {
            Wafu10WashiBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroBookCoverSection
                    statusStampSection
                    verticalStepsSection
                    noticeTadashigakiSection
                    primaryActionSection
                    hanreiFeaturesSection
                    colophonFooterSection
                }
                .padding(.leading, 16)
                .padding(.trailing, 38)
                .padding(.top, 22)
                .padding(.bottom, 36)
            }

            // 右端の和綴じ（四つ目綴じ）と揺れる栞紐
            Wafu10WatojiBinding(ribbonSway: ribbonSway)
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                sealPulse = true
            }
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                ribbonSway = true
            }
        }
    }

    // MARK: 1. ヒーロー（題簽と縦書き序文）

    private var heroBookCoverSection: some View {
        HStack(alignment: .top, spacing: 0) {
            // 左側：タグ 3 つ（木版小札）と縦書きのひとこと（右→左）
            VStack(alignment: .leading, spacing: 14) {
                // 縦書きのひとこと（ルビ付き、右から左へ読む）
                HStack(alignment: .top, spacing: 16) {
                    Spacer(minLength: 0)

                    // 左行（2行目）
                    Wafu10VerticalLine(
                        tokens: [
                            .ruby(base: "本", reading: "ほん"),
                            .plain("のように"),
                            .ruby(base: "読", reading: "よ"),
                            .plain("む")
                        ],
                        fontSize: 13.5,
                        color: Wafu10Palette.kozumi,
                        charSpacing: 2.0
                    )
                    .padding(.top, 14)

                    // 右行（1行目）
                    Wafu10VerticalLine(
                        tokens: [
                            .plain("ウェブの"),
                            .ruby(base: "文章", reading: "ぶんしょう"),
                            .plain("を、")
                        ],
                        fontSize: 13.5,
                        color: Wafu10Palette.kozumi,
                        charSpacing: 2.0
                    )
                    .padding(.trailing, 8)
                }
                .padding(.top, 6)

                Spacer(minLength: 4)

                // 小さなタグ 3 つ
                HStack(spacing: 5) {
                    woodblockTag("v1.0")
                    woodblockTag("iOS 18+")
                    woodblockTag("Safari")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 14)

            // 細い縦界線
            Rectangle()
                .fill(Wafu10Palette.keisen)
                .frame(width: 0.7)
                .padding(.vertical, 4)

            // 右側：和本の題簽（だいせん）— マーク＋縦書き「よみび」
            VStack(spacing: 10) {
                Wafu10BookSealMark()

                Wafu10VerticalLine(
                    tokens: [
                        .ruby(base: "よみび", reading: "読日", rubyColor: Wafu10Palette.honshu.opacity(0.85))
                    ],
                    fontSize: 25,
                    bold: true,
                    color: Wafu10Palette.kozumi,
                    charSpacing: 3.0
                )
                .padding(.trailing, 10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Wafu10Palette.torinoko)
            .overlay(
                Rectangle()
                    .stroke(Wafu10Palette.kozumi.opacity(0.45), lineWidth: 0.6)
                    .padding(2.5)
            )
            .overlay(
                Rectangle()
                    .stroke(Wafu10Palette.kozumi, lineWidth: 1.2)
            )
            .padding(.leading, 14)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(14)
        .wafu10DoubleBorder()
    }

    private func woodblockTag(_ text: String) -> some View {
        Text(text)
            .font(Wafu10Fonts.sans(10, weight: .medium))
            .tracking(0.4)
            .foregroundStyle(Wafu10Palette.usuzumi)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Wafu10Palette.oldWashi.opacity(0.8))
            .overlay(
                Rectangle()
                    .stroke(Wafu10Palette.keisen, lineWidth: 0.8)
            )
    }

    // MARK: 2. 状態表示（改め印カード）

    private var statusStampSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                extState = extState.next
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("現在の具合")
                            .font(Wafu10Fonts.mincho(10.5))
                            .tracking(1.2)
                            .foregroundStyle(Wafu10Palette.usuzumi)

                        Text("・押して切替")
                            .font(Wafu10Fonts.sans(10))
                            .foregroundStyle(Wafu10Palette.usuzumi.opacity(0.75))
                    }

                    Text(extState.title)
                        .font(Wafu10Fonts.mincho(15, bold: true))
                        .tracking(0.8)
                        .foregroundStyle(Wafu10Palette.kozumi)

                    Text(extState.detail)
                        .font(Wafu10Fonts.mincho(11.5))
                        .foregroundStyle(Wafu10Palette.usuzumi)
                        .lineSpacing(3)
                }

                Spacer(minLength: 4)

                // 縦書き角印（静かな呼吸明滅）
                VStack(spacing: 1) {
                    ForEach(Array(extState.sealText.enumerated()), id: \.offset) { _, ch in
                        Text(String(ch))
                            .font(Wafu10Fonts.mincho(11, bold: true))
                            .foregroundStyle(extState.sealColor)
                    }
                }
                .frame(width: 30, height: 42)
                .background(extState.sealColor.opacity(0.07))
                .overlay(
                    Rectangle()
                        .stroke(extState.sealColor, lineWidth: 1.4)
                )
                .overlay(
                    Rectangle()
                        .stroke(extState.sealColor.opacity(0.5), lineWidth: 0.5)
                        .padding(2.5)
                )
                .opacity(sealPulse ? 1.0 : 0.72)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .wafu10DoubleBorder(
                outer: Wafu10Palette.kozumi.opacity(0.85),
                inner: Wafu10Palette.keisen,
                background: Wafu10Palette.torinoko.opacity(0.82)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("拡張の状態、\(extState.title)。タップして切り替え")
    }

    // MARK: 3. 手順 4 つ（古書の版面：右から左へ縦書き・界線・ルビ・割注）

    private var verticalStepsSection: some View {
        VStack(spacing: 0) {
            // 版面の柱（上部の見出し帯）
            HStack {
                Text("右より読む ◀")
                    .font(Wafu10Fonts.sans(9.5))
                    .foregroundStyle(Wafu10Palette.usuzumi)

                Spacer()

                HStack(spacing: 4) {
                    Text("設定の次第")
                        .font(Wafu10Fonts.mincho(12.5, bold: true))
                        .tracking(2.0)
                        .foregroundStyle(Wafu10Palette.kozumi)
                    Text("一〜四")
                        .font(Wafu10Fonts.mincho(10.5))
                        .foregroundStyle(Wafu10Palette.usuzumi)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Wafu10Palette.oldWashi.opacity(0.85))

            Rectangle()
                .fill(Wafu10Palette.kozumi.opacity(0.65))
                .frame(height: 0.8)

            // 縦書き 4 列（左が四、右が一 — 和本の右→左の読み順）
            HStack(alignment: .top, spacing: 0) {
                // 【四】強調する手順（朱枠・傍点・朱の割注）
                stepFourColumn
                    .frame(maxWidth: .infinity)

                verticalKeisen

                // 【三】
                stepThreeColumn
                    .frame(width: 56)

                verticalKeisen

                // 【二】
                stepTwoColumn
                    .frame(width: 54)

                verticalKeisen

                // 【一】（最右・ここから読み始める）
                stepOneColumn
                    .frame(maxWidth: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .wafu10DoubleBorder(background: Wafu10Palette.torinoko.opacity(0.75))
    }

    private var verticalKeisen: some View {
        Rectangle()
            .fill(Wafu10Palette.keisen)
            .frame(width: 0.7)
            .padding(.vertical, 8)
    }

    private func stepBadge(_ kanji: String, highlighted: Bool = false) -> some View {
        Text(kanji)
            .font(Wafu10Fonts.mincho(11, bold: true))
            .foregroundStyle(highlighted ? Wafu10Palette.torinoko : Wafu10Palette.kozumi)
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .fill(highlighted ? Wafu10Palette.honshu : Wafu10Palette.oldWashi)
            )
            .overlay(
                Circle()
                    .stroke(highlighted ? Wafu10Palette.honshu : Wafu10Palette.kozumi.opacity(0.6), lineWidth: 0.8)
            )
    }

    /// 手順 一（最右列）：縦書き 2 行＋割注
    private var stepOneColumn: some View {
        VStack(spacing: 8) {
            stepBadge("一")

            HStack(alignment: .top, spacing: 8) {
                // 左行（続き＋割注）
                Wafu10VerticalLine(
                    tokens: [
                        .plain("「"),
                        .latin("Safari", height: 34),
                        .plain("」→「機能拡張」を開く"),
                        .warichu(
                            rightLine: "設定アプリの",
                            leftLine: "いちばん下のほう",
                            color: Wafu10Palette.usuzumi
                        )
                    ],
                    fontSize: 12.2,
                    color: Wafu10Palette.kozumi,
                    charSpacing: 1.0
                )

                // 右行（書き出し）
                Wafu10VerticalLine(
                    tokens: [
                        .ruby(base: "設定", reading: "せってい"),
                        .plain("アプリで「アプリ」→")
                    ],
                    fontSize: 12.2,
                    color: Wafu10Palette.kozumi,
                    charSpacing: 1.0
                )
                .padding(.trailing, 7)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 5)
    }

    /// 手順 二
    private var stepTwoColumn: some View {
        VStack(spacing: 8) {
            stepBadge("二")

            Wafu10VerticalLine(
                tokens: [
                    .plain("「よみび」をオンにする")
                ],
                fontSize: 12.2,
                color: Wafu10Palette.kozumi,
                charSpacing: 1.5
            )

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }

    /// 手順 三
    private var stepThreeColumn: some View {
        VStack(spacing: 8) {
            stepBadge("三")

            Wafu10VerticalLine(
                tokens: [
                    .latin("Safari", height: 34),
                    .plain("で好きな"),
                    .ruby(base: "記事", reading: "きじ"),
                    .plain("を"),
                    .ruby(base: "開", reading: "ひら"),
                    .plain("く")
                ],
                fontSize: 12.2,
                color: Wafu10Palette.kozumi,
                charSpacing: 1.5
            )

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }

    /// 手順 四（最左列・強調：朱敷き＋傍点＋朱の割注）
    private var stepFourColumn: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text("要")
                    .font(Wafu10Fonts.mincho(9.5, bold: true))
                    .foregroundStyle(Wafu10Palette.honshu)
                stepBadge("四", highlighted: true)
            }

            HStack(alignment: .top, spacing: 10) {
                // 左行（要所＋傍点＋朱の割注）
                Wafu10VerticalLine(
                    tokens: [
                        .plain("「"),
                        .bouten("よみび", dotColor: Wafu10Palette.honshu),
                        .plain("」を"),
                        .ruby(base: "選", reading: "えら", rubyColor: Wafu10Palette.honshu),
                        .plain("ぶ"),
                        .warichu(
                            rightLine: "ここで初めて",
                            leftLine: "本文が整う",
                            color: Wafu10Palette.honshu
                        )
                    ],
                    fontSize: 12.5,
                    bold: true,
                    color: Wafu10Palette.kozumi,
                    charSpacing: 1.1
                )

                // 右行（書き出し）
                Wafu10VerticalLine(
                    tokens: [
                        .plain("アドレスバーの「"),
                        .bouten("ぁあ", dotColor: Wafu10Palette.honshu),
                        .plain("」から")
                    ],
                    fontSize: 12.5,
                    bold: true,
                    color: Wafu10Palette.kozumi,
                    charSpacing: 1.1
                )
                .padding(.trailing, 5)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(Wafu10Palette.usushu.opacity(0.85))
        .overlay(
            Rectangle()
                .stroke(Wafu10Palette.honshu.opacity(0.65), lineWidth: 1.0)
                .padding(3)
        )
    }

    // MARK: 4. 注意カード（古書の但し書き）

    private var noticeTadashigakiSection: some View {
        HStack(alignment: .top, spacing: 11) {
            // 小さな朱印「但」
            Text("但")
                .font(Wafu10Fonts.mincho(12, bold: true))
                .foregroundStyle(Wafu10Palette.torinoko)
                .frame(width: 24, height: 24)
                .background(Wafu10Palette.honshu)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("サイトごとに許可が要る")
                    .font(Wafu10Fonts.mincho(13.5, bold: true))
                    .tracking(0.6)
                    .foregroundStyle(Wafu10Palette.kozumi)

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(Wafu10Fonts.mincho(11.5))
                    .foregroundStyle(Wafu10Palette.usuzumi)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 12)
        .wafu10DoubleBorder(
            outer: Wafu10Palette.honshu.opacity(0.75),
            inner: Wafu10Palette.honshu.opacity(0.32),
            background: Wafu10Palette.oldWashi.opacity(0.92)
        )
    }

    // MARK: 5. 主ボタン（藍表紙の端正な短冊ボタン）

    private var primaryActionSection: some View {
        Link(destination: Self.safariURL) {
            HStack {
                Spacer()
                Text("Safari を開く")
                    .font(Wafu10Fonts.mincho(15.5, bold: true))
                    .tracking(2.4)
                    .foregroundStyle(Wafu10Palette.torinoko)

                Text("→")
                    .font(Wafu10Fonts.sans(13.5, weight: .light))
                    .foregroundStyle(Wafu10Palette.bindingThread)
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.vertical, 15)
            .background(Wafu10Palette.aiCover)
            .overlay(
                Rectangle()
                    .stroke(Wafu10Palette.bindingThread.opacity(0.45), lineWidth: 0.7)
                    .padding(3.5)
            )
            .overlay(
                Rectangle()
                    .stroke(Wafu10Palette.kozumi, lineWidth: 1.0)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: 6. 説明 3 行（凡例：縦書き 3 列＋木版アイコン）

    private var hanreiFeaturesSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("三箇条")
                    .font(Wafu10Fonts.mincho(10))
                    .tracking(1.0)
                    .foregroundStyle(Wafu10Palette.usuzumi)
                Spacer()
                Text("凡例")
                    .font(Wafu10Fonts.mincho(12, bold: true))
                    .tracking(3.0)
                    .foregroundStyle(Wafu10Palette.kozumi)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Wafu10Palette.oldWashi.opacity(0.85))

            Rectangle()
                .fill(Wafu10Palette.kozumi.opacity(0.55))
                .frame(height: 0.7)

            // 右から左へ 3 条（縦書き）
            HStack(alignment: .top, spacing: 0) {
                // 左列（三条）
                hanreiColumn(
                    icon: .ribbonMark,
                    rightLine: [
                        .ruby(base: "読", reading: "よ"),
                        .plain("んだ"),
                        .ruby(base: "位置", reading: "いち"),
                        .plain("を")
                    ],
                    leftLine: [
                        .ruby(base: "覚", reading: "おぼ"),
                        .plain("えておく")
                    ]
                )

                verticalKeisen

                // 中央列（二条）
                hanreiColumn(
                    icon: .lineMeasure,
                    rightLine: [
                        .ruby(base: "行間", reading: "ぎょうかん"),
                        .plain("と文字の大きさを")
                    ],
                    leftLine: [
                        .ruby(base: "端末", reading: "たんまつ"),
                        .plain("に合わせる")
                    ]
                )

                verticalKeisen

                // 右列（一条）
                hanreiColumn(
                    icon: .verticalType,
                    rightLine: [
                        .ruby(base: "本文", reading: "ほんもん"),
                        .plain("だけを抜き出して")
                    ],
                    leftLine: [
                        .ruby(base: "明朝体", reading: "みんちょうたい"),
                        .plain("で組む")
                    ]
                )
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .wafu10DoubleBorder(background: Wafu10Palette.torinoko.opacity(0.7))
    }

    private func hanreiColumn(
        icon: Wafu10FeatureIconKind,
        rightLine: [Wafu10VerticalToken],
        leftLine: [Wafu10VerticalToken]
    ) -> some View {
        VStack(spacing: 10) {
            Wafu10WoodblockIcon(kind: icon)

            HStack(alignment: .top, spacing: 11) {
                Wafu10VerticalLine(tokens: leftLine, fontSize: 11.8, color: Wafu10Palette.kozumi, charSpacing: 1.0)
                Wafu10VerticalLine(tokens: rightLine, fontSize: 11.8, color: Wafu10Palette.kozumi, charSpacing: 1.0)
                    .padding(.trailing, 7)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }

    // MARK: 7. 足元（奥付・蔵書印）

    private var colophonFooterSection: some View {
        VStack(spacing: 10) {
            VStack(spacing: 2) {
                Rectangle()
                    .fill(Wafu10Palette.kozumi.opacity(0.6))
                    .frame(height: 1.0)
                Rectangle()
                    .fill(Wafu10Palette.keisen)
                    .frame(height: 0.6)
            }

            HStack(alignment: .center, spacing: 10) {
                // 小さな蔵書印「読日」
                VStack(spacing: 0) {
                    Text("読")
                        .font(Wafu10Fonts.mincho(8.5, bold: true))
                    Text("日")
                        .font(Wafu10Fonts.mincho(8.5, bold: true))
                }
                .foregroundStyle(Wafu10Palette.honshu)
                .frame(width: 18, height: 26)
                .overlay(
                    Rectangle()
                        .stroke(Wafu10Palette.honshu, lineWidth: 1.0)
                )

                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(Wafu10Fonts.mincho(11))
                    .tracking(0.6)
                    .foregroundStyle(Wafu10Palette.usuzumi)

                Spacer(minLength: 0)
            }
        }
        .padding(.top, 2)
    }
}

#Preview {
    Wafu10Screen()
}
