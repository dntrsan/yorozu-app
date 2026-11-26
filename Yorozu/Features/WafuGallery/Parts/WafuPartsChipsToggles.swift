import SwiftUI

// MARK: - Private Color Helper & Palette

private extension Color {
    init(wpctHex: UInt32, alpha: Double = 1.0) {
        let r = Double((wpctHex >> 16) & 0xFF) / 255.0
        let g = Double((wpctHex >> 8) & 0xFF) / 255.0
        let b = Double(wpctHex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum WPCTPalette {
    static let washiLight = Color(wpctHex: 0xF6F3EB)
    static let cardLight = Color(wpctHex: 0xFCFBF7)
    static let inkLight = Color(wpctHex: 0x1E1C19)
    static let subLight = Color(wpctHex: 0x676158)
    static let lineLight = Color(wpctHex: 0xDDD7C9)

    static let sumiDark = Color(wpctHex: 0x151412)
    static let cardDark = Color(wpctHex: 0x1E1C19)
    static let inkDark = Color(wpctHex: 0xEFECE4)
    static let subDark = Color(wpctHex: 0x9C9589)
    static let lineDark = Color(wpctHex: 0x33302A)

    static let shu = Color(wpctHex: 0xB8372B)          // 朱
    static let shuDark = Color(wpctHex: 0xDC6255)      // 暗地朱
    static let ai = Color(wpctHex: 0x223B55)           // 藍
    static let aiDark = Color(wpctHex: 0x5B86B0)       // 暗地藍
    static let kin = Color(wpctHex: 0xB69249)          // 金茶
    static let hinoki = Color(wpctHex: 0xEADAC0)       // 檜
    static let hinokiDark = Color(wpctHex: 0x372D21)   // 暗地檜
    static let tokiwa = Color(wpctHex: 0x38664A)       // 常盤
    static let wakatake = Color(wpctHex: 0x6AA37E)     // 若竹
    static let akari = Color(wpctHex: 0xDF9A35)        // 山吹
    static let kokutan = Color(wpctHex: 0x2E241E)      // 黒檀
    static let kurumi = Color(wpctHex: 0x8F7558)       // 胡桃
    static let nibi = Color(wpctHex: 0x7B756D)         // 鈍
}

// MARK: - 1. 千社札タグ（せんじゃふだ）— WPCTSenjafudaChip

/// 二重の子持ち枠と差し色帯を備えた江戸の千社札風タグ。
struct WPCTSenjafudaChip: View {
    var text: String
    var accent: Color
    var isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    init(
        _ text: String,
        accent: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169),
        isSelected: Bool = false
    ) {
        self.text = text
        self.accent = accent
        self.isSelected = isSelected
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let baseBg = isSelected ? accent : (isDark ? WPCTPalette.cardDark : WPCTPalette.cardLight)
        let fg = isSelected ? Color(wpctHex: 0xFAF7F0) : (isDark ? WPCTPalette.inkDark : WPCTPalette.inkLight)
        let outerFrame = isSelected ? accent : (isDark ? Color(wpctHex: 0xB5AFA4) : Color(wpctHex: 0x262320))

        HStack(spacing: 6) {
            // 差し札の小帯
            Rectangle()
                .fill(isSelected ? Color(wpctHex: 0xFAF7F0).opacity(0.85) : accent)
                .frame(width: 4, height: 14)

            Text(text)
                .font(.custom("HiraMinProN-W6", size: 11.5))
                .foregroundStyle(fg)
        }
        .padding(.leading, 6)
        .padding(.trailing, 10)
        .padding(.vertical, 5)
        .background(baseBg)
        .overlay(
            Rectangle()
                .stroke(outerFrame, lineWidth: 1.5)
        )
        .overlay(
            Rectangle()
                .stroke(outerFrame.opacity(0.5), lineWidth: 0.6)
                .padding(2.5)
        )
    }
}

// MARK: - 2. のし紙タグ（のしがみ）— WPCTNoshigamiChip

/// 右上に紅白の折り熨斗を添えた端正な和紙タグ。
struct WPCTNoshigamiChip: View {
    var text: String
    var isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    init(_ text: String, isSelected: Bool = false) {
        self.text = text
        self.isSelected = isSelected
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let bg = isDark ? Color(wpctHex: 0x211F1B) : Color(wpctHex: 0xFEFDF9)
        let fg = isDark ? WPCTPalette.inkDark : WPCTPalette.inkLight
        let border = isSelected
            ? WPCTPalette.kin
            : (isDark ? WPCTPalette.lineDark : WPCTPalette.lineLight)
        let shu = isDark ? WPCTPalette.shuDark : WPCTPalette.shu

        HStack(spacing: 6) {
            Text(text)
                .font(.custom("HiraMinProN-W6", size: 11.5))
                .foregroundStyle(fg)
                .padding(.leading, 10)
                .padding(.trailing, 16)
                .padding(.vertical, 5.5)
        }
        .background(bg)
        .overlay(alignment: .topTrailing) {
            // 右上の紅白折り熨斗
            Canvas { ctx, size in
                var redFold = Path()
                redFold.move(to: CGPoint(x: size.width - 14, y: 0))
                redFold.addLine(to: CGPoint(x: size.width, y: 0))
                redFold.addLine(to: CGPoint(x: size.width, y: 14))
                redFold.closeSubpath()
                ctx.fill(redFold, with: .color(shu))

                var goldStripe = Path()
                goldStripe.move(to: CGPoint(x: size.width - 10, y: 0))
                goldStripe.addLine(to: CGPoint(x: size.width, y: 10))
                ctx.stroke(goldStripe, with: .color(WPCTPalette.kin), lineWidth: 1.4)
            }
            .frame(width: 16, height: 16)
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(border, lineWidth: isSelected ? 1.4 : 1.0)
        )
    }
}

// MARK: - 3. 荷札タグ（にふだ）— WPCTKifudaChip

private struct WPCTNifudaShape: Shape {
    var bevel: CGFloat = 8.0

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let b = min(bevel, rect.height * 0.42)
        p.move(to: CGPoint(x: rect.minX + b, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - 3, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + 3),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 3))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX - 3, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        p.addLine(to: CGPoint(x: rect.minX + b, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

/// 左肩を切り落とし鳩目（ハトメ）穴を設けた生成りの荷札タグ。
struct WPCTKifudaChip: View {
    var text: String
    var isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    init(_ text: String, isSelected: Bool = false) {
        self.text = text
        self.isSelected = isSelected
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let bg: Color = {
            if isSelected {
                return isDark ? WPCTPalette.hinokiDark : WPCTPalette.hinoki
            }
            return isDark ? Color(wpctHex: 0x24211D) : Color(wpctHex: 0xEFEAE0)
        }()
        let border = isSelected
            ? (isDark ? WPCTPalette.kin : Color(wpctHex: 0xA68148))
            : (isDark ? WPCTPalette.lineDark : Color(wpctHex: 0xCFC7B8))
        let holeRing = isSelected
            ? (isDark ? WPCTPalette.shuDark : WPCTPalette.shu)
            : (isDark ? Color(wpctHex: 0x8F8578) : Color(wpctHex: 0x9C8C75))
        let fg = isDark ? WPCTPalette.inkDark : Color(wpctHex: 0x262019)

        HStack(spacing: 6) {
            Circle()
                .fill(isDark ? WPCTPalette.sumiDark : WPCTPalette.washiLight)
                .frame(width: 6.5, height: 6.5)
                .overlay(Circle().stroke(holeRing, lineWidth: 1.5))

            Text(text)
                .font(.custom("HiraMinProN-W6", size: 11.5))
                .foregroundStyle(fg)
        }
        .padding(.leading, 11)
        .padding(.trailing, 10)
        .padding(.vertical, 5.5)
        .background(bg)
        .clipShape(WPCTNifudaShape(bevel: 9))
        .overlay(WPCTNifudaShape(bevel: 9).stroke(border, lineWidth: 1.1))
    }
}

// MARK: - 4. 入隅・題簽タグ（いりずみ）— WPCTKirikoChip

private struct WPCTIrizumiShape: Shape {
    var notch: CGFloat = 4.5

    func path(in rect: CGRect) -> Path {
        let r = min(notch, min(rect.width, rect.height) * 0.28)
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(
            center: CGPoint(x: rect.maxX, y: rect.minY),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(
            center: CGPoint(x: rect.maxX, y: rect.maxY),
            radius: r,
            startAngle: .degrees(270),
            endAngle: .degrees(180),
            clockwise: true
        )
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addArc(
            center: CGPoint(x: rect.minX, y: rect.maxY),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(270),
            clockwise: true
        )
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addArc(
            center: CGPoint(x: rect.minX, y: rect.minY),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(0),
            clockwise: true
        )
        p.closeSubpath()
        return p
    }
}

/// 四隅を内弧で切り欠いた、和本題簽（だいせん）風の入隅チップ。
struct WPCTKirikoChip: View {
    var text: String
    var accent: Color
    var isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    init(
        _ text: String,
        accent: Color = Color(.sRGB, red: 0.133, green: 0.231, blue: 0.333),
        isSelected: Bool = false
    ) {
        self.text = text
        self.accent = accent
        self.isSelected = isSelected
    }

    var body: some View {
        let isDark = colorScheme == .dark
        let bg = isSelected ? accent : (isDark ? WPCTPalette.cardDark : WPCTPalette.cardLight)
        let fg = isSelected ? Color(wpctHex: 0xF7F4EC) : (isDark ? WPCTPalette.inkDark : accent)
        let strokeCol = isSelected ? accent : (isDark ? accent.opacity(0.85) : accent.opacity(0.7))

        Text(text)
            .font(.custom("HiraMinProN-W6", size: 11.5))
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 5.5)
            .background(bg)
            .clipShape(WPCTIrizumiShape(notch: 4.5))
            .overlay(WPCTIrizumiShape(notch: 4.5).stroke(strokeCol, lineWidth: 1.15))
    }
}

// MARK: - 5. 障子戸トグル（しょうじど）— WPCTShojiToggleStyle

/// 敷居の上を組子格子の障子戸が滑る数寄屋風トグルスイッチ。
struct WPCTShojiToggleStyle: ToggleStyle {
    init() {}

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: ToggleStyle.Configuration
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let isDark = colorScheme == .dark
            let isOn = configuration.isOn
            let trackBg = isOn
                ? (isDark ? Color(wpctHex: 0x2F4435) : Color(wpctHex: 0xDDE8DC))
                : (isDark ? Color(wpctHex: 0x262420) : Color(wpctHex: 0xE7E1D4))
            let frameCol = isDark ? Color(wpctHex: 0x7A6D5C) : Color(wpctHex: 0x6E5D4B)
            let shojiPaper = isDark ? Color(wpctHex: 0xEAE2D2) : Color(wpctHex: 0xFFFDF8)
            let accentLight = isDark ? WPCTPalette.wakatake : WPCTPalette.tokiwa

            HStack(spacing: 12) {
                configuration.label
                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        configuration.isOn.toggle()
                    }
                } label: {
                    ZStack(alignment: isOn ? .trailing : .leading) {
                        // 敷居（トラック）
                        RoundedRectangle(cornerRadius: 4)
                            .fill(trackBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(frameCol, lineWidth: 1.3)
                            )
                            .overlay(alignment: .leading) {
                                if isOn {
                                    Circle()
                                        .fill(accentLight)
                                        .frame(width: 6, height: 6)
                                        .padding(.leading, 9)
                                }
                            }

                        // 障子戸のつまみ
                        ZStack {
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(shojiPaper)
                            // 組子格子
                            Rectangle().fill(frameCol.opacity(0.6)).frame(width: 0.8)
                            Rectangle().fill(frameCol.opacity(0.6)).frame(height: 0.8)
                            RoundedRectangle(cornerRadius: 2.5)
                                .stroke(frameCol, lineWidth: 1.1)
                        }
                        .frame(width: 24, height: 22)
                        .padding(3)
                    }
                    .frame(width: 54, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityValue(isOn ? "オン" : "オフ")
            }
        }
    }
}

// MARK: - 6. 表裏木札トグル（おもてうらきふだ）— WPCTKifudaToggleStyle

/// 「入／切」を彫り込んだ隅切り木札が左右に滑る江戸風トグルスイッチ。
struct WPCTKifudaToggleStyle: ToggleStyle {
    init() {}

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: ToggleStyle.Configuration
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let isDark = colorScheme == .dark
            let isOn = configuration.isOn
            let trackBg = isOn
                ? (isDark ? WPCTPalette.hinokiDark : WPCTPalette.hinoki)
                : (isDark ? Color(wpctHex: 0x24221F) : Color(wpctHex: 0xE6E0D5))
            let border = isOn
                ? (isDark ? WPCTPalette.kin : Color(wpctHex: 0xAD8A52))
                : (isDark ? WPCTPalette.lineDark : Color(wpctHex: 0xC6BEB0))
            let knobBg = isOn
                ? (isDark ? WPCTPalette.shuDark : WPCTPalette.shu)
                : (isDark ? Color(wpctHex: 0x524D46) : Color(wpctHex: 0x8F887E))

            HStack(spacing: 12) {
                configuration.label
                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                        configuration.isOn.toggle()
                    }
                } label: {
                    ZStack(alignment: isOn ? .trailing : .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(trackBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(border, lineWidth: 1.2)
                            )

                        HStack {
                            Text("入")
                                .font(.custom("HiraMinProN-W6", size: 10))
                                .foregroundStyle(isOn ? (isDark ? WPCTPalette.inkDark : Color(wpctHex: 0x3D2E1A)) : .clear)
                            Spacer()
                            Text("切")
                                .font(.custom("HiraMinProN-W6", size: 10))
                                .foregroundStyle(!isOn ? WPCTPalette.nibi : .clear)
                        }
                        .padding(.horizontal, 8)

                        RoundedRectangle(cornerRadius: 3.5)
                            .fill(knobBg)
                            .overlay(
                                Circle()
                                    .fill(Color(wpctHex: 0xFAF6EE).opacity(0.85))
                                    .frame(width: 4.5, height: 4.5)
                            )
                            .frame(width: 22, height: 22)
                            .padding(3)
                    }
                    .frame(width: 56, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityValue(isOn ? "入" : "切")
            }
        }
    }
}

// MARK: - 7. 水引結びトグル（みずひき）— WPCTMizuhikiToggleStyle

/// 二本の水引紐の上を梅結び風の円形つまみが滑る軽やかなトグルスイッチ。
struct WPCTMizuhikiToggleStyle: ToggleStyle {
    init() {}

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: ToggleStyle.Configuration
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let isDark = colorScheme == .dark
            let isOn = configuration.isOn
            let cord1 = isOn
                ? (isDark ? WPCTPalette.shuDark : WPCTPalette.shu)
                : (isDark ? Color(wpctHex: 0x4E4A44) : Color(wpctHex: 0xBFB8AC))
            let cord2 = isOn
                ? WPCTPalette.kin
                : (isDark ? Color(wpctHex: 0x3B3833) : Color(wpctHex: 0xD3CDC2))
            let knobBg = isDark ? WPCTPalette.cardDark : WPCTPalette.cardLight

            HStack(spacing: 12) {
                configuration.label
                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                        configuration.isOn.toggle()
                    }
                } label: {
                    ZStack(alignment: isOn ? .trailing : .leading) {
                        // 二本の水引紐
                        VStack(spacing: 3.5) {
                            Capsule().fill(cord1).frame(height: 2.2)
                            Capsule().fill(cord2).frame(height: 1.8)
                        }
                        .padding(.horizontal, 4)

                        // 水引の輪結びつまみ
                        ZStack {
                            Circle().fill(knobBg)
                            Circle().stroke(cord1, lineWidth: 2.0)
                            Circle()
                                .stroke(cord2, lineWidth: 1.2)
                                .padding(4)
                            if isOn {
                                Circle()
                                    .fill(cord1)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .frame(width: 24, height: 24)
                    }
                    .frame(width: 54, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityValue(isOn ? "オン" : "オフ")
            }
        }
    }
}

// MARK: - 8. 算盤玉トグル（そろばんだま）— WPCTSorobanToggleStyle

private struct WPCTSorobanBeadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let dx = rect.width * 0.48
        let dy = rect.height * 0.46
        p.move(to: CGPoint(x: cx, y: cy - dy))
        p.addLine(to: CGPoint(x: cx + dx, y: cy - dy * 0.28))
        p.addLine(to: CGPoint(x: cx + dx, y: cy + dy * 0.28))
        p.addLine(to: CGPoint(x: cx, y: cy + dy))
        p.addLine(to: CGPoint(x: cx - dx, y: cy + dy * 0.28))
        p.addLine(to: CGPoint(x: cx - dx, y: cy - dy * 0.28))
        p.closeSubpath()
        return p
    }
}

/// 竹軸の上を算盤玉が小気味よく左右に動く工芸風トグルスイッチ。
struct WPCTSorobanToggleStyle: ToggleStyle {
    init() {}

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration)
    }

    private struct BodyView: View {
        let configuration: ToggleStyle.Configuration
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let isDark = colorScheme == .dark
            let isOn = configuration.isOn
            let frameBg = isDark ? Color(wpctHex: 0x241F1B) : Color(wpctHex: 0xEFEAE0)
            let woodBorder = isDark ? Color(wpctHex: 0x6D5A48) : WPCTPalette.kokutan
            let rodColor = isDark ? Color(wpctHex: 0x8F7F6A) : Color(wpctHex: 0xB8A382)
            let beadFill = isOn
                ? (isDark ? Color(wpctHex: 0xC4924A) : Color(wpctHex: 0xA87332))
                : (isDark ? Color(wpctHex: 0x574D43) : Color(wpctHex: 0x8A7C6C))
            let activeDot = isDark ? WPCTPalette.akari : WPCTPalette.shu

            HStack(spacing: 12) {
                configuration.label
                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.85)) {
                        configuration.isOn.toggle()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(frameBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(woodBorder, lineWidth: 1.8)
                            )

                        // 竹ひご軸
                        Rectangle()
                            .fill(rodColor)
                            .frame(height: 2.0)
                            .padding(.horizontal, 4)

                        // 左端の定位点
                        HStack {
                            Circle()
                                .fill(isOn ? activeDot : rodColor.opacity(0.6))
                                .frame(width: 5, height: 5)
                                .padding(.leading, 8)
                            Spacer()
                        }

                        // 算盤玉
                        HStack {
                            if isOn { Spacer() }
                            WPCTSorobanBeadShape()
                                .fill(beadFill)
                                .overlay(
                                    WPCTSorobanBeadShape()
                                        .stroke(woodBorder.opacity(0.7), lineWidth: 1.0)
                                )
                                .frame(width: 24, height: 20)
                                .padding(.horizontal, 4)
                            if !isOn { Spacer() }
                        }
                    }
                    .frame(width: 56, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityValue(isOn ? "オン" : "オフ")
            }
        }
    }
}

// MARK: - 見本帳 Gallery View

struct WafuPartsChipsTogglesGallery: View {
    @State private var isDarkChrome: Bool = false
    @State private var selectedTag: String = "Safari"

    @State private var shojiOn: Bool = true
    @State private var kifudaOn: Bool = true
    @State private var mizuhikiOn: Bool = false
    @State private var sorobanOn: Bool = true

    private let tags = ["v1.0", "iOS 18+", "Safari"]

    init() {}

    var body: some View {
        let bg = isDarkChrome ? WPCTPalette.sumiDark : WPCTPalette.washiLight
        let card = isDarkChrome ? WPCTPalette.cardDark : WPCTPalette.cardLight
        let fg = isDarkChrome ? WPCTPalette.inkDark : WPCTPalette.inkLight
        let sub = isDarkChrome ? WPCTPalette.subDark : WPCTPalette.subLight
        let line = isDarkChrome ? WPCTPalette.lineDark : WPCTPalette.lineLight

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection(fg: fg, sub: sub, line: line)

                // 紙面切替
                HStack {
                    Text("見本帳の紙面")
                        .font(.custom("HiraMinProN-W6", size: 12))
                        .foregroundStyle(fg)
                    Spacer()
                    Picker("紙面", selection: $isDarkChrome) {
                        Text("白練（明）").tag(false)
                        Text("墨色（暗）").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 190)
                }
                .padding(12)
                .background(card)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // 前半: タグ 4種
                sectionHeading("タグ・札（4種）", sub: "タップで選択状態を切り替えられます", fg: fg, subCol: sub)

                chipCard(name: "一、千社札", reading: "せんじゃふだ", desc: "子持ち枠と差し色帯が粋な江戸風タグ", card: card, fg: fg, sub: sub, line: line) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { t in
                            Button { selectedTag = t } label: {
                                WPCTSenjafudaChip(
                                    t,
                                    accent: isDarkChrome ? WPCTPalette.shuDark : WPCTPalette.shu,
                                    isSelected: selectedTag == t
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                chipCard(name: "二、のし紙", reading: "のしがみ", desc: "右上に紅白の折り熨斗を添えた端正な和紙タグ", card: card, fg: fg, sub: sub, line: line) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { t in
                            Button { selectedTag = t } label: {
                                WPCTNoshigamiChip(t, isSelected: selectedTag == t)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                chipCard(name: "三、荷札", reading: "にふだ", desc: "肩落としと鳩目穴をあしらった生成りの木札タグ", card: card, fg: fg, sub: sub, line: line) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { t in
                            Button { selectedTag = t } label: {
                                WPCTKifudaChip(t, isSelected: selectedTag == t)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                chipCard(name: "四、入隅・題簽", reading: "いりずみ", desc: "四隅を内弧で切り欠いた和本の題簽風チップ", card: card, fg: fg, sub: sub, line: line) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { t in
                            Button { selectedTag = t } label: {
                                WPCTKirikoChip(
                                    t,
                                    accent: isDarkChrome ? WPCTPalette.aiDark : WPCTPalette.ai,
                                    isSelected: selectedTag == t
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // 後半: トグルスイッチ 4種
                sectionHeading("トグルスイッチ（4種）", sub: "すべて標準の ToggleStyle として利用可能", fg: fg, subCol: sub)

                VStack(spacing: 12) {
                    toggleCard(name: "五、障子戸", reading: "しょうじど", desc: "組子格子の障子が敷居の上をすっと滑る", card: card, fg: fg, sub: sub, line: line) {
                        Toggle(isOn: $shojiOn) {
                            toggleLabel("本文を明朝体で組む", note: "よみびの基本整形", fg: fg, sub: sub)
                        }
                        .toggleStyle(WPCTShojiToggleStyle())
                    }

                    toggleCard(name: "六、表裏木札", reading: "おもてうらきふだ", desc: "「入／切」を刻んだ檜の木札スイッチ", card: card, fg: fg, sub: sub, line: line) {
                        Toggle(isOn: $kifudaOn) {
                            toggleLabel("行間と文字サイズを端末に合わせる", note: "読みやすい幅へ自動調整", fg: fg, sub: sub)
                        }
                        .toggleStyle(WPCTKifudaToggleStyle())
                    }

                    toggleCard(name: "七、水引結び", reading: "みずひき", desc: "紅白二本の水引紐を輪結びのつまみが滑る", card: card, fg: fg, sub: sub, line: line) {
                        Toggle(isOn: $mizuhikiOn) {
                            toggleLabel("読んだ位置を覚えておく", note: "次回の再訪時に続きから", fg: fg, sub: sub)
                        }
                        .toggleStyle(WPCTMizuhikiToggleStyle())
                    }

                    toggleCard(name: "八、算盤玉", reading: "そろばんだま", desc: "黒檀枠と竹軸の上を算盤玉が小気味よく動く", card: card, fg: fg, sub: sub, line: line) {
                        Toggle(isOn: $sorobanOn) {
                            toggleLabel("Safari 機能拡張を有効にする", note: "アドレスバーの「ぁあ」から起動", fg: fg, sub: sub)
                        }
                        .toggleStyle(WPCTSorobanToggleStyle())
                    }
                }

                Text("よみび 1.0 ・ タグとトグル 8種見本帳")
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(sub)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 14)
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
                Text("タグとトグル 見本帳")
                    .font(.custom("HiraMinProN-W6", size: 22))
                    .foregroundStyle(fg)
                Spacer()
                Text("計 8種")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(sub)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(Capsule().stroke(line, lineWidth: 1))
            }
            Text("札・千社札・のし紙をモチーフにしたタグ 4 種と、障子戸や算盤玉などの独自 ToggleStyle 4 種。")
                .font(.system(size: 12))
                .foregroundStyle(sub)
                .lineSpacing(3)
        }
    }

    private func sectionHeading(_ title: String, sub: String, fg: Color, subCol: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 16))
                .foregroundStyle(fg)
            Text(sub)
                .font(.system(size: 11))
                .foregroundStyle(subCol)
        }
        .padding(.top, 4)
    }

    private func chipCard<Content: View>(
        name: String,
        reading: String,
        desc: String,
        card: Color,
        fg: Color,
        sub: Color,
        line: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(name)
                    .font(.custom("HiraMinProN-W6", size: 14))
                    .foregroundStyle(fg)
                Text(reading)
                    .font(.custom("HiraMinProN-W3", size: 10.5))
                    .foregroundStyle(sub)
            }
            Text(desc)
                .font(.system(size: 11))
                .foregroundStyle(sub)
            content()
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(card)
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }

    private func toggleCard<Content: View>(
        name: String,
        reading: String,
        desc: String,
        card: Color,
        fg: Color,
        sub: Color,
        line: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(name)
                    .font(.custom("HiraMinProN-W6", size: 14))
                    .foregroundStyle(fg)
                Text(reading)
                    .font(.custom("HiraMinProN-W3", size: 10.5))
                    .foregroundStyle(sub)
                Spacer()
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundStyle(sub)
                    .lineLimit(1)
            }
            Divider().overlay(line)
            content()
        }
        .padding(14)
        .background(card)
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }

    private func toggleLabel(_ title: String, note: String, fg: Color, sub: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 13.5))
                .foregroundStyle(fg)
            Text(note)
                .font(.system(size: 11))
                .foregroundStyle(sub)
        }
    }
}

#Preview {
    WafuPartsChipsTogglesGallery()
}
