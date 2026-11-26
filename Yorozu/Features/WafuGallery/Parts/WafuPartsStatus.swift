import SwiftUI

// MARK: - Private Color Helper & Palette

private extension Color {
    init(wpsHex: UInt32, alpha: Double = 1.0) {
        let r = Double((wpsHex >> 16) & 0xFF) / 255.0
        let g = Double((wpsHex >> 8) & 0xFF) / 255.0
        let b = Double(wpsHex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum WPStatusPalette {
    // 紙面・墨
    static let washiLight = Color(wpsHex: 0xF6F2E9)
    static let cardLight = Color(wpsHex: 0xFDFBF6)
    static let inkLight = Color(wpsHex: 0x1F1D1A)
    static let subLight = Color(wpsHex: 0x666057)
    static let lineLight = Color(wpsHex: 0xDFD9CC)

    static let sumiDark = Color(wpsHex: 0x151412)
    static let cardDark = Color(wpsHex: 0x1F1D1A)
    static let inkDark = Color(wpsHex: 0xF0ECE3)
    static let subDark = Color(wpsHex: 0x9F988C)
    static let lineDark = Color(wpsHex: 0x33302A)

    // 伝統アクセント色
    static let akari = Color(wpsHex: 0xDF9B36)       // 山吹灯火
    static let akariGlow = Color(wpsHex: 0xF4C96B)   // 灯り暈し
    static let shuin = Color(wpsHex: 0xB8372B)       // 朱肉
    static let shuinDark = Color(wpsHex: 0xDC6255)   // 暗地用朱
    static let kin = Color(wpsHex: 0xB89448)         // 金茶
    static let ai = Color(wpsHex: 0x223A54)          // 藍
    static let asagi = Color(wpsHex: 0x4A7C8C)       // 浅葱
    static let tokiwa = Color(wpsHex: 0x3A6B4C)      // 常盤緑
    static let wakatake = Color(wpsHex: 0x6DA37F)    // 若竹
    static let hisui = Color(wpsHex: 0x2E7D63)       // 翡翠
    static let hinoki = Color(wpsHex: 0xE8D7B7)      // 檜木地
    static let hinokiDark = Color(wpsHex: 0x342B20)  // 暗地檜
    static let kurumi = Color(wpsHex: 0x8F7A62)      // 胡桃
    static let nibi = Color(wpsHex: 0x7A756D)        // 鈍色
    static let moonGold = Color(wpsHex: 0xE6CA7E)    // 月光金
    static let nightSky = Color(wpsHex: 0x1B2536)    // 藍鉄夜空
}

// MARK: - 共通状態モデル

enum WPStatusState: String, CaseIterable, Identifiable, Sendable {
    case on
    case off
    case checking

    var id: String { rawValue }

    func next() -> WPStatusState {
        switch self {
        case .on: return .off
        case .off: return .checking
        case .checking: return .on
        }
    }

    var shortLabel: String {
        switch self {
        case .on: return "オン"
        case .off: return "オフ"
        case .checking: return "確認中"
        }
    }

    var defaultTitle: String {
        switch self {
        case .on: return "よみびは有効です"
        case .off: return "よみびはオフです"
        case .checking: return "状態を確認しています…"
        }
    }

    var defaultSubtitle: String {
        switch self {
        case .on: return "Safari の本文を明朝体で整えます"
        case .off: return "設定アプリで機能拡張をオンにしてください"
        case .checking: return "Safari 機能拡張の応答を待っています"
        }
    }
}

// MARK: - 1. 灯籠（とうろう）— WPStatusToroCard

/// 行灯・障子灯籠の火袋に灯る明かりで状態を示すカード。
struct WPStatusToroCard: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme
    @State private var glowPulse: Bool = false

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let cardBg = isDark ? Color(wpsHex: 0x201D18) : Color(wpsHex: 0xFBF7EE)
        let border = state == .on
            ? WPStatusPalette.akari.opacity(isDark ? 0.50 : 0.42)
            : (isDark ? WPStatusPalette.lineDark : WPStatusPalette.lineLight)
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight

        HStack(spacing: 14) {
            toroGlyph(isDark: isDark)
                .frame(width: 44, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(title ?? state.defaultTitle)
                        .font(.custom("HiraMinProN-W6", size: 14.5))
                        .foregroundStyle(fg)
                    Spacer(minLength: 4)
                    Text(toroBadgeText)
                        .font(.custom("HiraMinProN-W3", size: 10.5))
                        .foregroundStyle(toroAccent(isDark: isDark))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(toroAccent(isDark: isDark).opacity(0.12))
                        .clipShape(Capsule())
                }
                Text(subtitle ?? state.defaultSubtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(sub)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    private var toroBadgeText: String {
        switch state {
        case .on: return "点灯"
        case .off: return "消灯"
        case .checking: return "火種"
        }
    }

    private func toroAccent(isDark: Bool) -> Color {
        switch state {
        case .on: return isDark ? WPStatusPalette.akariGlow : Color(wpsHex: 0xB87314)
        case .off: return WPStatusPalette.nibi
        case .checking: return WPStatusPalette.asagi
        }
    }

    private func toroGlyph(isDark: Bool) -> some View {
        let frameColor = isDark ? Color(wpsHex: 0xB5A894) : Color(wpsHex: 0x4A3F33)
        let paperOff = isDark ? Color(wpsHex: 0x2B2823) : Color(wpsHex: 0xECE5D8)

        return ZStack {
            if state == .on {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WPStatusPalette.akariGlow.opacity(glowPulse ? 0.55 : 0.30),
                                WPStatusPalette.akari.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 24
                        )
                    )
            }

            Canvas { ctx, size in
                let w = size.width
                let h = size.height
                let cx = w * 0.5

                // 屋根（笠）
                var roof = Path()
                roof.move(to: CGPoint(x: cx, y: 3))
                roof.addLine(to: CGPoint(x: w * 0.88, y: 12))
                roof.addLine(to: CGPoint(x: w * 0.12, y: 12))
                roof.closeSubpath()
                ctx.fill(roof, with: .color(frameColor))

                // 火袋（和紙窓）
                let bodyRect = CGRect(x: w * 0.22, y: 12, width: w * 0.56, height: h - 22)
                if state == .on {
                    let grad = Gradient(colors: [Color(wpsHex: 0xFFF4CE), WPStatusPalette.akari])
                    ctx.fill(
                        Path(bodyRect),
                        with: .radialGradient(
                            grad,
                            center: CGPoint(x: cx, y: bodyRect.midY),
                            startRadius: 1,
                            endRadius: 18
                        )
                    )
                } else {
                    ctx.fill(Path(bodyRect), with: .color(paperOff))
                }

                // 確認中の小さな火種
                if state == .checking {
                    let flameR: CGFloat = glowPulse ? 4.4 : 3.2
                    let flameRect = CGRect(
                        x: cx - flameR,
                        y: bodyRect.midY - flameR,
                        width: flameR * 2,
                        height: flameR * 2
                    )
                    ctx.fill(Path(ellipseIn: flameRect), with: .color(WPStatusPalette.akari))
                }

                // 格子枠
                var grid = Path()
                grid.addRect(bodyRect)
                grid.move(to: CGPoint(x: cx, y: bodyRect.minY))
                grid.addLine(to: CGPoint(x: cx, y: bodyRect.maxY))
                grid.move(to: CGPoint(x: bodyRect.minX, y: bodyRect.midY))
                grid.addLine(to: CGPoint(x: bodyRect.maxX, y: bodyRect.midY))
                ctx.stroke(grid, with: .color(frameColor), lineWidth: 1.4)

                // 台座
                let baseRect = CGRect(x: w * 0.16, y: h - 10, width: w * 0.68, height: 4.5)
                ctx.fill(Path(roundedRect: baseRect, cornerRadius: 1.5), with: .color(frameColor))
            }
        }
    }
}

// MARK: - 2. 朱印（しゅいん）— WPStatusShuinBadge

/// 古印の落款枠で状態を示す、書物の奥付風ステータスカード。
struct WPStatusShuinBadge: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let cardBg = isDark ? WPStatusPalette.cardDark : WPStatusPalette.cardLight
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let line = isDark ? WPStatusPalette.lineDark : WPStatusPalette.lineLight
        let stampColor = stampTint(isDark: isDark)

        HStack(spacing: 14) {
            // 落款印
            ZStack {
                if state == .on {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(stampColor)
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(cardBg.opacity(0.65), lineWidth: 1)
                        .padding(3.5)
                    Text("効")
                        .font(.custom("HiraMinProN-W6", size: 22))
                        .foregroundStyle(cardBg)
                } else if state == .off {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(stampColor, lineWidth: 1.4)
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(stampColor.opacity(0.45), lineWidth: 0.8)
                        .padding(3.5)
                    Text("未")
                        .font(.custom("HiraMinProN-W6", size: 20))
                        .foregroundStyle(stampColor)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            stampColor,
                            style: StrokeStyle(lineWidth: 1.4, dash: [4, 2.5])
                        )
                    Text("伺")
                        .font(.custom("HiraMinProN-W6", size: 20))
                        .foregroundStyle(stampColor)
                }
            }
            .frame(width: 44, height: 44)
            .rotationEffect(.degrees(state == .on ? -3.5 : 0))

            VStack(alignment: .leading, spacing: 3) {
                Text(title ?? state.defaultTitle)
                    .font(.custom("HiraMinProN-W6", size: 14.5))
                    .foregroundStyle(fg)
                Text(subtitle ?? state.defaultSubtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(sub)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func stampTint(isDark: Bool) -> Color {
        switch state {
        case .on: return isDark ? WPStatusPalette.shuinDark : WPStatusPalette.shuin
        case .off: return WPStatusPalette.nibi
        case .checking: return WPStatusPalette.kin
        }
    }
}

// MARK: - 3. 水引（みずひき）— WPStatusMizuhikiStrip

/// のし紙に掛ける水引の結び（結び済み／ほどけ／結びかけ）で状態を示す和紙帯。
struct WPStatusMizuhikiStrip: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let cardBg = isDark ? Color(wpsHex: 0x1D1B18) : Color(wpsHex: 0xFCFBF8)
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let line = isDark ? WPStatusPalette.lineDark : WPStatusPalette.lineLight

        VStack(alignment: .leading, spacing: 10) {
            // 水引ラインと結び目
            mizuhikiRibbon(isDark: isDark)
                .frame(height: 24)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? state.defaultTitle)
                        .font(.custom("HiraMinProN-W6", size: 14.5))
                        .foregroundStyle(fg)
                    Text(subtitle ?? state.defaultSubtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(sub)
                }
                Spacer(minLength: 8)
                Text(mizuhikiLabel)
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(primaryCord(isDark: isDark))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var mizuhikiLabel: String {
        switch state {
        case .on: return "結び済"
        case .off: return "未結び"
        case .checking: return "整え中"
        }
    }

    private func primaryCord(isDark: Bool) -> Color {
        switch state {
        case .on: return isDark ? WPStatusPalette.shuinDark : WPStatusPalette.shuin
        case .off: return WPStatusPalette.nibi
        case .checking: return WPStatusPalette.asagi
        }
    }

    private func secondaryCord(isDark: Bool) -> Color {
        switch state {
        case .on: return WPStatusPalette.kin
        case .off: return WPStatusPalette.nibi.opacity(0.45)
        case .checking: return isDark ? Color(wpsHex: 0xBCC6CE) : Color(wpsHex: 0x90A3B0)
        }
    }

    private func mizuhikiRibbon(isDark: Bool) -> some View {
        let c1 = primaryCord(isDark: isDark)
        let c2 = secondaryCord(isDark: isDark)

        return Canvas { ctx, size in
            let midY = size.height * 0.5
            let cx = size.width * 0.5

            if state == .off {
                // ほどけて左右に途切れた水引
                var p1 = Path()
                p1.move(to: CGPoint(x: 0, y: midY - 2))
                p1.addLine(to: CGPoint(x: cx - 16, y: midY - 2))
                p1.move(to: CGPoint(x: cx + 16, y: midY - 2))
                p1.addLine(to: CGPoint(x: size.width, y: midY - 2))

                var p2 = Path()
                p2.move(to: CGPoint(x: 0, y: midY + 2))
                p2.addLine(to: CGPoint(x: cx - 10, y: midY + 2))
                p2.move(to: CGPoint(x: cx + 10, y: midY + 2))
                p2.addLine(to: CGPoint(x: size.width, y: midY + 2))

                ctx.stroke(p1, with: .color(c1), lineWidth: 1.5)
                ctx.stroke(p2, with: .color(c2), lineWidth: 1.2)
            } else {
                // 左右の帯線
                var base1 = Path()
                base1.move(to: CGPoint(x: 0, y: midY - 2))
                base1.addLine(to: CGPoint(x: size.width, y: midY - 2))
                var base2 = Path()
                base2.move(to: CGPoint(x: 0, y: midY + 2))
                base2.addLine(to: CGPoint(x: size.width, y: midY + 2))

                ctx.stroke(base1, with: .color(c1), lineWidth: 1.5)
                ctx.stroke(base2, with: .color(c2), lineWidth: 1.3)

                // あわじ結び（中央の三輪）
                let r: CGFloat = 7.5
                var knot1 = Path()
                knot1.addEllipse(in: CGRect(x: cx - r * 1.65, y: midY - r, width: r * 2, height: r * 2))
                knot1.addEllipse(in: CGRect(x: cx - r * 0.35, y: midY - r, width: r * 2, height: r * 2))

                var knot2 = Path()
                let innerR: CGFloat = 5.0
                knot2.addEllipse(in: CGRect(x: cx - innerR, y: midY - innerR, width: innerR * 2, height: innerR * 2))

                if state == .on {
                    ctx.stroke(knot1, with: .color(c1), lineWidth: 2.0)
                    ctx.stroke(knot2, with: .color(c2), lineWidth: 1.6)
                } else {
                    ctx.stroke(
                        knot1,
                        with: .color(c1),
                        style: StrokeStyle(lineWidth: 1.8, dash: [4, 2.5])
                    )
                    ctx.stroke(knot2, with: .color(c2), lineWidth: 1.4)
                }
            }
        }
    }
}

// MARK: - 4. 暖簾（のれん）— WPStatusNorenBanner

/// 書肆の軒先に掛かる三連の暖簾で開店／閉店／準備中を表すカード。
struct WPStatusNorenBanner: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let cardBg = isDark ? WPStatusPalette.cardDark : WPStatusPalette.cardLight
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let line = isDark ? WPStatusPalette.lineDark : WPStatusPalette.lineLight
        let rodColor = isDark ? Color(wpsHex: 0x7E6A52) : Color(wpsHex: 0x5E4934)
        let clothColor = norenColor(isDark: isDark)
        let panelHeight: CGFloat = state == .off ? 14 : 30

        VStack(alignment: .leading, spacing: 10) {
            // 竹竿と三連暖簾
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(rodColor)
                    .frame(height: 3.5)

                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { idx in
                        ZStack {
                            clothColor
                            if state != .off && idx == 1 {
                                Text(state == .on ? "開" : "調")
                                    .font(.custom("HiraMinProN-W6", size: 13))
                                    .foregroundStyle(Color(wpsHex: 0xF7F3EA))
                            }
                        }
                        .frame(height: panelHeight)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 3,
                                bottomTrailingRadius: 3,
                                topTrailingRadius: 0
                            )
                        )
                    }
                }
                .padding(.horizontal, 6)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? state.defaultTitle)
                        .font(.custom("HiraMinProN-W6", size: 14.5))
                        .foregroundStyle(fg)
                    Text(subtitle ?? state.defaultSubtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(sub)
                }
                Spacer(minLength: 6)
                Text(state == .on ? "暖簾掛" : (state == .off ? "仕舞い" : "準備中"))
                    .font(.custom("HiraMinProN-W3", size: 10.5))
                    .foregroundStyle(sub)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func norenColor(isDark: Bool) -> Color {
        switch state {
        case .on: return isDark ? Color(wpsHex: 0x35587B) : WPStatusPalette.ai
        case .off: return isDark ? Color(wpsHex: 0x3D3933) : Color(wpsHex: 0xC6BFAF)
        case .checking: return WPStatusPalette.asagi
        }
    }
}

// MARK: - 5. 月齢（げつれい）— WPStatusMoonPhase

/// 満月・新月・三日月の盈虧（えいき）で状態を表す雅なカード。
struct WPStatusMoonPhase: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let cardBg = isDark ? Color(wpsHex: 0x181D27) : Color(wpsHex: 0xF5F4F0)
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let border = isDark ? Color(wpsHex: 0x2C3546) : Color(wpsHex: 0xDAD7CE)

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(WPStatusPalette.nightSky)
                moonCanvas
                    .frame(width: 28, height: 28)
            }
            .frame(width: 44, height: 44)
            .overlay(Circle().stroke(WPStatusPalette.moonGold.opacity(state == .on ? 0.55 : 0.2), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title ?? state.defaultTitle)
                        .font(.custom("HiraMinProN-W6", size: 14.5))
                        .foregroundStyle(fg)
                    Spacer(minLength: 4)
                    Text(moonName)
                        .font(.custom("HiraMinProN-W3", size: 11))
                        .foregroundStyle(isDark ? WPStatusPalette.moonGold : Color(wpsHex: 0x7A6329))
                }
                Text(subtitle ?? state.defaultSubtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(sub)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var moonName: String {
        switch state {
        case .on: return "望月"
        case .off: return "朔月"
        case .checking: return "三日月"
        }
    }

    private var moonCanvas: some View {
        Canvas { ctx, size in
            let rect = CGRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
            switch state {
            case .on:
                ctx.fill(Path(ellipseIn: rect), with: .color(WPStatusPalette.moonGold))
            case .off:
                ctx.stroke(
                    Path(ellipseIn: rect),
                    with: .color(WPStatusPalette.moonGold.opacity(0.45)),
                    lineWidth: 1.2
                )
            case .checking:
                ctx.drawLayer { layer in
                    layer.fill(Path(ellipseIn: rect), with: .color(WPStatusPalette.moonGold))
                    let cutRect = rect.offsetBy(dx: -rect.width * 0.36, dy: -rect.height * 0.08)
                    layer.blendMode = .destinationOut
                    layer.fill(Path(ellipseIn: cutRect), with: .color(.black))
                }
            }
        }
    }
}

// MARK: - 6. 枯山水（かれさんすい）— WPStatusKaresansuiBar

/// 砂紋の整い方と景石の色で静かに状態を示す禅スタイルの横帯。
struct WPStatusKaresansuiBar: View {
    var state: WPStatusState
    var title: String?
    var subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil, subtitle: String? = nil) {
        self.state = state
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let sandBg = isDark ? Color(wpsHex: 0x22201C) : Color(wpsHex: 0xF3EFE5)
        let lineCol = isDark ? Color(wpsHex: 0x3D3931) : Color(wpsHex: 0xD8D0C0)
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let stoneCol = stoneColor(isDark: isDark)

        ZStack(alignment: .leading) {
            sandBg
            // 背景の砂紋
            Canvas { ctx, size in
                let grooveColor = isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.07)
                var path = Path()
                let rows = 5
                let spacing = size.height / CGFloat(rows + 1)

                if state == .on {
                    for i in 1...rows {
                        let y = CGFloat(i) * spacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                } else if state == .checking {
                    for i in 1...rows {
                        let y = CGFloat(i) * spacing
                        path.move(to: CGPoint(x: 0, y: y))
                        var x: CGFloat = 0
                        while x <= size.width {
                            let waveY = y + sin(x * 0.08 + CGFloat(i)) * 2.2
                            path.addLine(to: CGPoint(x: x, y: waveY))
                            x += 8
                        }
                    }
                }
                ctx.stroke(path, with: .color(grooveColor), lineWidth: 1.0)
            }

            HStack(spacing: 12) {
                // 景石（2石組）
                Canvas { ctx, size in
                    var bigStone = Path()
                    bigStone.move(to: CGPoint(x: 4, y: 28))
                    bigStone.addQuadCurve(to: CGPoint(x: 16, y: 8), control: CGPoint(x: 6, y: 12))
                    bigStone.addQuadCurve(to: CGPoint(x: 32, y: 28), control: CGPoint(x: 28, y: 10))
                    bigStone.closeSubpath()
                    ctx.fill(bigStone, with: .color(stoneCol))

                    var smallStone = Path()
                    smallStone.move(to: CGPoint(x: 24, y: 29))
                    smallStone.addQuadCurve(to: CGPoint(x: 34, y: 18), control: CGPoint(x: 26, y: 19))
                    smallStone.addQuadCurve(to: CGPoint(x: 42, y: 29), control: CGPoint(x: 40, y: 20))
                    smallStone.closeSubpath()
                    ctx.fill(smallStone, with: .color(stoneCol.opacity(0.72)))
                }
                .frame(width: 44, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title ?? state.defaultTitle)
                        .font(.custom("HiraMinProN-W6", size: 14))
                        .foregroundStyle(fg)
                    Text(subtitle ?? state.defaultSubtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(sub)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(lineCol, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func stoneColor(isDark: Bool) -> Color {
        switch state {
        case .on: return isDark ? WPStatusPalette.wakatake : WPStatusPalette.tokiwa
        case .off: return WPStatusPalette.nibi
        case .checking: return WPStatusPalette.kin
        }
    }
}

// MARK: - 7. 木札（きふだ）— WPStatusKifudaPill

private struct WPSKifudaShape: Shape {
    var cut: CGFloat = 7.0

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = min(cut, min(rect.width, rect.height) * 0.35)
        p.move(to: CGPoint(x: rect.minX + c, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - c, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + c))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - c))
        p.addLine(to: CGPoint(x: rect.maxX - c, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + c, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - c))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + c))
        p.closeSubpath()
        return p
    }
}

/// 隅切りの木札と組紐穴で状態を表すコンパクトな江戸風ピル部品。
struct WPStatusKifudaPill: View {
    var state: WPStatusState
    var title: String?

    @Environment(\.colorScheme) private var colorScheme

    init(state: WPStatusState, title: String? = nil) {
        self.state = state
        self.title = title
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let woodBg: Color = {
            if state == .on {
                return isDark ? WPStatusPalette.hinokiDark : WPStatusPalette.hinoki
            } else {
                return isDark ? Color(wpsHex: 0x252320) : Color(wpsHex: 0xEAE4D9)
            }
        }()
        let border = state == .on
            ? (isDark ? WPStatusPalette.kin.opacity(0.65) : Color(wpsHex: 0xB89865))
            : (isDark ? WPStatusPalette.lineDark : Color(wpsHex: 0xC9C0B1))
        let fg = isDark ? WPStatusPalette.inkDark : Color(wpsHex: 0x2A2219)
        let dotCol: Color = {
            switch state {
            case .on: return isDark ? WPStatusPalette.shuinDark : WPStatusPalette.shuin
            case .off: return WPStatusPalette.nibi
            case .checking: return WPStatusPalette.kin
            }
        }()

        HStack(spacing: 9) {
            // 紐通し穴
            Circle()
                .stroke(border, lineWidth: 1.3)
                .background(Circle().fill(isDark ? WPStatusPalette.sumiDark : WPStatusPalette.washiLight))
                .frame(width: 9, height: 9)

            Rectangle()
                .fill(border.opacity(0.7))
                .frame(width: 1, height: 18)

            Circle()
                .fill(dotCol)
                .frame(width: 7.5, height: 7.5)

            Text(title ?? state.defaultTitle)
                .font(.custom("HiraMinProN-W6", size: 13.5))
                .foregroundStyle(fg)

            Spacer(minLength: 4)

            Text(state == .on ? "表・稼働" : (state == .off ? "裏・休止" : "確認中"))
                .font(.custom("HiraMinProN-W3", size: 10.5))
                .foregroundStyle(isDark ? WPStatusPalette.subDark : WPStatusPalette.kurumi)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(woodBg)
        .clipShape(WPSKifudaShape(cut: 7))
        .overlay(WPSKifudaShape(cut: 7).stroke(border, lineWidth: 1.2))
    }
}

// MARK: - 8. 和玉・三連珠（わだま）— WPStatusTamaIndicator

/// 翡翠・鈍・琥珀の三連和玉で状態を静かに知らせるコンパクト帯。
struct WPStatusTamaIndicator: View {
    var state: WPStatusState
    var title: String?

    @Environment(\.colorScheme) private var colorScheme
    @State private var shimmer: Bool = false

    init(state: WPStatusState, title: String? = nil) {
        self.state = state
        self.title = title
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let bg = isDark ? WPStatusPalette.cardDark : WPStatusPalette.cardLight
        let fg = isDark ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDark ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let line = isDark ? WPStatusPalette.lineDark : WPStatusPalette.lineLight

        HStack(spacing: 12) {
            // 組紐に並ぶ3つの和玉
            ZStack {
                Rectangle()
                    .fill(line)
                    .frame(width: 48, height: 1.4)
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        tamaBead(index: index, isDark: isDark)
                    }
                }
            }
            .frame(width: 54, height: 18)

            Text(title ?? state.defaultTitle)
                .font(.custom("HiraMinProN-W6", size: 13.5))
                .foregroundStyle(fg)

            Spacer(minLength: 4)

            Text(state.shortLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(sub)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(bg)
        .overlay(Capsule().stroke(line, lineWidth: 1))
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    private func tamaBead(index: Int, isDark: Bool) -> some View {
        let baseColor: Color = {
            switch state {
            case .on:
                return isDark ? Color(wpsHex: 0x56A88B) : WPStatusPalette.hisui
            case .off:
                return isDark ? Color(wpsHex: 0x4E4A44) : Color(wpsHex: 0xB8B1A6)
            case .checking:
                return WPStatusPalette.akari
            }
        }()

        let beadOpacity: Double = {
            if state == .checking {
                if index == 1 { return shimmer ? 1.0 : 0.45 }
                return shimmer ? 0.45 : 0.95
            }
            return 1.0
        }()

        return Circle()
            .fill(
                RadialGradient(
                    colors: [Color.white.opacity(state == .off ? 0.2 : 0.55), baseColor],
                    center: .topLeading,
                    startRadius: 1,
                    endRadius: 9
                )
            )
            .frame(width: 11, height: 11)
            .opacity(beadOpacity)
    }
}

// MARK: - 見本帳 Gallery View

struct WafuPartsStatusGallery: View {
    @State private var state: WPStatusState = .on { didSet { WafuHaptics.tap() } }
    @State private var isDarkChrome: Bool = false

    init() {}

    var body: some View {
        let bg = isDarkChrome ? WPStatusPalette.sumiDark : WPStatusPalette.washiLight
        let fg = isDarkChrome ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDarkChrome ? WPStatusPalette.subDark : WPStatusPalette.subLight
        let line = isDarkChrome ? WPStatusPalette.lineDark : WPStatusPalette.lineLight

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(fg: fg, sub: sub, line: line)
                controlBar(fg: fg, sub: sub, line: line)

                sampleSection("一、灯籠", reading: "とうろう", desc: "行灯の火袋に灯る温かな光で拡張の有効状態を示す") {
                    WPStatusToroCard(state: state)
                }
                sampleSection("二、朱印", reading: "しゅいん", desc: "奥付の落款のように「効／未／伺」で凛と判を示す") {
                    WPStatusShuinBadge(state: state)
                }
                sampleSection("三、水引", reading: "みずひき", desc: "あわじ結びの結・解で接続状態を端正に表現する") {
                    WPStatusMizuhikiStrip(state: state)
                }
                sampleSection("四、暖簾", reading: "のれん", desc: "書肆の三連暖簾が開き・仕舞いで稼働を一目で伝える") {
                    WPStatusNorenBanner(state: state)
                }
                sampleSection("五、月齢", reading: "げつれい", desc: "望月・朔月・三日月の満ち欠けで静かに知らせる") {
                    WPStatusMoonPhase(state: state)
                }
                sampleSection("六、枯山水", reading: "かれさんすい", desc: "砂紋の整いと景石の苔色で余白を活かす禅スタイル") {
                    WPStatusKaresansuiBar(state: state)
                }
                sampleSection("七、木札", reading: "きふだ", desc: "隅切りの檜札を裏返す所作を模した江戸風の横札") {
                    WPStatusKifudaPill(state: state)
                }
                sampleSection("八、和玉", reading: "わだま", desc: "翡翠・鈍・琥珀の三連珠で省スペースに状態を示す") {
                    WPStatusTamaIndicator(state: state)
                }

                Text("よみび 1.0 ・ 状態表示パーツ 8種見本帳（タップで状態巡回）")
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(sub)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
        }
        .background(bg.ignoresSafeArea())
        .preferredColorScheme(isDarkChrome ? .dark : .light)
    }

    private func headerSection(fg: Color, sub: Color, line: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("状態表示 見本帳")
                    .font(.custom("HiraMinProN-W6", size: 22))
                    .foregroundStyle(fg)
                Spacer()
                Text("3状態 × 8種")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(sub)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(Capsule().stroke(line, lineWidth: 1))
            }
            Text("オン・オフ・確認中を和の佇まいで伝える部品集。上部の切替か、各部品のタップで状態を巡回できます。")
                .font(.system(size: 12))
                .foregroundStyle(sub)
                .lineSpacing(3)
        }
    }

    private func controlBar(fg: Color, sub: Color, line: Color) -> some View {
        VStack(spacing: 10) {
            Picker("状態", selection: $state.wafuHaptic()) {
                Text("オン").tag(WPStatusState.on)
                Text("オフ").tag(WPStatusState.off)
                Text("確認中").tag(WPStatusState.checking)
            }
            .pickerStyle(.segmented)

            HStack {
                Text("紙面")
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .foregroundStyle(fg)
                Spacer()
                Picker("紙面", selection: $isDarkChrome.wafuHaptic()) {
                    Text("白練（明）").tag(false)
                    Text("墨色（暗）").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 190)
            }
        }
        .padding(12)
        .background(isDarkChrome ? WPStatusPalette.cardDark : WPStatusPalette.cardLight)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func sampleSection<Content: View>(
        _ name: String,
        reading: String,
        desc: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let fg = isDarkChrome ? WPStatusPalette.inkDark : WPStatusPalette.inkLight
        let sub = isDarkChrome ? WPStatusPalette.subDark : WPStatusPalette.subLight

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(name)
                    .font(.custom("HiraMinProN-W6", size: 14.5))
                    .foregroundStyle(fg)
                Text(reading)
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(sub)
            }
            Text(desc)
                .font(.system(size: 11.5))
                .foregroundStyle(sub)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    state = state.next()
                }
            } label: {
                content()
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    WafuPartsStatusGallery()
}
