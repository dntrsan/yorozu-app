import SwiftUI

// MARK: - Palette

private enum Wafu15Palette {
    static let paper = hex(0xFAF5EC)        // 胡粉生成り（地色）
    static let card = hex(0xFFFFFF)         // 白紙（カード）
    static let warmTint = hex(0xFFF8E3)     // 淡山吹（注意カード地）
    static let ink = hex(0x1E2433)          // 墨藍（主文字・罫線）
    static let mutedInk = hex(0x5A6173)     // 薄墨藍（補足文字）
    static let subtleLine = hex(0xE6DDD0)   // 淡い紙線

    // 千代紙 4 色
    static let beni = hex(0xE64833)         // 朱紅
    static let beniLight = hex(0xFDEAE6)    // 淡紅
    static let ai = hex(0x1F4E8C)           // 藍青
    static let aiLight = hex(0xE8F0FA)      // 淡藍
    static let yamabuki = hex(0xF2B11A)     // 山吹
    static let matsuba = hex(0x278B67)      // 松葉
    static let matsubaLight = hex(0xE5F4EE) // 淡松葉

    static func hex(_ value: UInt32, alpha: Double = 1.0) -> Color {
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Main Screen

struct Wafu15Screen: View {
    enum ExtState: CaseIterable {
        case on
        case off
        case checking

        var next: ExtState {
            switch self {
            case .on: return .off
            case .off: return .checking
            case .checking: return .on
            }
        }

        var badgeText: String {
            switch self {
            case .on: return "オン"
            case .off: return "オフ"
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
            case .on: return "Safari からいつでも明朝体で読めます"
            case .off: return "下の 4 つの手順でオンにしましょう"
            case .checking: return "Safari の設定を読み込んでいます…"
            }
        }

        var accentColor: Color {
            switch self {
            case .on: return Wafu15Palette.matsuba
            case .off: return Wafu15Palette.beni
            case .checking: return Wafu15Palette.yamabuki
            }
        }

        var tintColor: Color {
            switch self {
            case .on: return Wafu15Palette.matsubaLight
            case .off: return Wafu15Palette.beniLight
            case .checking: return Wafu15Palette.warmTint
            }
        }
    }

    @State private var extState: ExtState = .on { didSet { WafuHaptics.tap() } }
    @State private var statusPulse: Bool = false
    @State private var highlightFloat: Bool = false

    private static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        ZStack {
            Wafu15Background()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Wafu15HeroCard()

                    Wafu15StatusCard(
                        state: extState,
                        pulse: statusPulse,
                        onTap: {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                                extState = extState.next
                            }
                        }
                    )

                    Wafu15StepsSection(highlightFloat: highlightFloat)

                    Wafu15NoticeCard()

                    Wafu15PrimaryButton(url: Self.safariURL)

                    Wafu15FeaturesCard()

                    Wafu15Footer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                statusPulse = true
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                highlightFloat = true
            }
        }
    }
}

// MARK: - Background

private struct Wafu15Background: View {
    var body: some View {
        ZStack {
            Wafu15Palette.paper

            // 和紙の極細繊維を思わせるごく淡い紙目
            Canvas { context, size in
                let step: CGFloat = 24
                var y: CGFloat = 12
                var row = 0
                while y < size.height {
                    var x: CGFloat = row.isMultiple(of: 2) ? 10 : 22
                    while x < size.width {
                        let dotRect = CGRect(x: x, y: y, width: 1.5, height: 1.5)
                        context.fill(
                            Path(ellipseIn: dotRect),
                            with: .color(Wafu15Palette.ink.opacity(0.035))
                        )
                        x += step
                    }
                    y += step
                    row += 1
                }
            }
        }
    }
}

// MARK: - Chiyogami Pattern Canvases

/// 麻の葉（Asanoha）
private struct Wafu15AsanohaPattern: View {
    let backgroundColor: Color
    let lineColor: Color
    var radius: CGFloat = 18
    var lineWidth: CGFloat = 1.1

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backgroundColor))

            let r = radius
            let dx: CGFloat = r * CGFloat(sqrt(3.0))
            let dy: CGFloat = r * 1.5
            let cols = Int(ceil(size.width / dx)) + 2
            let rows = Int(ceil(size.height / dy)) + 2

            var path = Path()

            for row in -1...rows {
                for col in -1...cols {
                    let offsetX: CGFloat = (row % 2 == 0) ? 0 : dx / 2.0
                    let cx = CGFloat(col) * dx + offsetX
                    let cy = CGFloat(row) * dy
                    let center = CGPoint(x: cx, y: cy)

                    var vertices: [CGPoint] = []
                    vertices.reserveCapacity(6)
                    for k in 0..<6 {
                        let angle = Double(k) * .pi / 3.0 - .pi / 2.0
                        let vx = cx + r * CGFloat(cos(angle))
                        let vy = cy + r * CGFloat(sin(angle))
                        vertices.append(CGPoint(x: vx, y: vy))
                    }

                    for k in 0..<6 {
                        let v1 = vertices[k]
                        let v2 = vertices[(k + 1) % 6]
                        let gx = (center.x + v1.x + v2.x) / 3.0
                        let gy = (center.y + v1.y + v2.y) / 3.0
                        let centroid = CGPoint(x: gx, y: gy)

                        // 外周と放射
                        path.move(to: v1)
                        path.addLine(to: v2)
                        path.move(to: center)
                        path.addLine(to: v1)

                        // 重心から3頂点へ
                        path.move(to: centroid)
                        path.addLine(to: center)
                        path.move(to: centroid)
                        path.addLine(to: v1)
                        path.move(to: centroid)
                        path.addLine(to: v2)
                    }
                }
            }

            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
        }
    }
}

/// 青海波（Seigaiha）
private struct Wafu15SeigaihaPattern: View {
    let backgroundColor: Color
    let waveColor: Color
    var radius: CGFloat = 16
    var lineWidth: CGFloat = 1.2

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backgroundColor))

            let r = radius
            let dx = r * 2.0
            let dy = r * 0.52
            let cols = Int(ceil(size.width / dx)) + 2
            let rows = Int(ceil(size.height / dy)) + 3

            for row in -1...rows {
                let shift: CGFloat = (row % 2 == 0) ? 0 : r
                let cy = CGFloat(row) * dy

                for col in -1...cols {
                    let cx = CGFloat(col) * dx + shift
                    let outerRect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: outerRect), with: .color(backgroundColor))

                    for scale in [1.0, 0.72, 0.44, 0.18] {
                        let sr = r * CGFloat(scale)
                        let rect = CGRect(x: cx - sr, y: cy - sr, width: sr * 2, height: sr * 2)
                        context.stroke(
                            Path(ellipseIn: rect),
                            with: .color(waveColor),
                            lineWidth: lineWidth
                        )
                    }
                }
            }
        }
    }
}

/// 市松（Ichimatsu）
private struct Wafu15IchimatsuPattern: View {
    let colorA: Color
    let colorB: Color
    var cellSize: CGFloat = 12

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(colorA))
            let cols = Int(ceil(size.width / cellSize)) + 1
            let rows = Int(ceil(size.height / cellSize)) + 1
            var path = Path()
            for row in 0..<rows {
                for col in 0..<cols where (row + col).isMultiple(of: 2) {
                    path.addRect(CGRect(
                        x: CGFloat(col) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    ))
                }
            }
            context.fill(path, with: .color(colorB))
        }
    }
}

/// 七宝（Shippo）
private struct Wafu15ShippoPattern: View {
    let backgroundColor: Color
    let ringColor: Color
    var diameter: CGFloat = 22
    var lineWidth: CGFloat = 1.25

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backgroundColor))

            let r = diameter / 2.0
            let cols = Int(ceil(size.width / diameter)) + 2
            let rows = Int(ceil(size.height / diameter)) + 2
            var path = Path()

            for row in -1...rows {
                for col in -1...cols {
                    let cx1 = CGFloat(col) * diameter
                    let cy1 = CGFloat(row) * diameter
                    path.addEllipse(in: CGRect(x: cx1 - r, y: cy1 - r, width: diameter, height: diameter))

                    let cx2 = cx1 + r
                    let cy2 = cy1 + r
                    path.addEllipse(in: CGRect(x: cx2 - r, y: cy2 - r, width: diameter, height: diameter))
                }
            }
            context.stroke(path, with: .color(ringColor), lineWidth: lineWidth)
        }
    }
}

/// 矢絣風シェブロン帯（注意カード用）
private struct Wafu15YagasuriStrip: View {
    let baseColor: Color
    let stripeColor: Color

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(baseColor))
            let unit: CGFloat = 14
            let count = Int(ceil(size.width / unit)) + 2
            var path = Path()
            for i in -1...count {
                let x = CGFloat(i) * unit
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + unit * 0.5, y: 0))
                path.addLine(to: CGPoint(x: x + unit * 0.95, y: 0))
                path.addLine(to: CGPoint(x: x + unit * 0.45, y: size.height))
                path.closeSubpath()
            }
            context.fill(path, with: .color(stripeColor))
        }
    }
}

// MARK: - App Mark (Origami Open Book)

private struct Wafu15AppMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Wafu15Palette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Wafu15Palette.ink, lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Wafu15Palette.ink)
                        .offset(x: 3, y: 3)
                )

            // 折り紙で折った「開いた本」としおり
            Canvas { context, size in
                let w = size.width
                let h = size.height

                // 奥の紙（松葉）
                var backLeaf = Path()
                backLeaf.move(to: CGPoint(x: w * 0.50, y: h * 0.24))
                backLeaf.addLine(to: CGPoint(x: w * 0.80, y: h * 0.20))
                backLeaf.addLine(to: CGPoint(x: w * 0.80, y: h * 0.66))
                backLeaf.addLine(to: CGPoint(x: w * 0.50, y: h * 0.76))
                backLeaf.closeSubpath()
                context.fill(backLeaf, with: .color(Wafu15Palette.matsuba))

                // 左ページ（朱紅）
                var leftPage = Path()
                leftPage.move(to: CGPoint(x: w * 0.18, y: h * 0.28))
                leftPage.addLine(to: CGPoint(x: w * 0.50, y: h * 0.36))
                leftPage.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
                leftPage.addLine(to: CGPoint(x: w * 0.18, y: h * 0.68))
                leftPage.closeSubpath()
                context.fill(leftPage, with: .color(Wafu15Palette.beni))

                // 右ページ（山吹）
                var rightPage = Path()
                rightPage.move(to: CGPoint(x: w * 0.82, y: h * 0.30))
                rightPage.addLine(to: CGPoint(x: w * 0.50, y: h * 0.36))
                rightPage.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
                rightPage.addLine(to: CGPoint(x: w * 0.82, y: h * 0.70))
                rightPage.closeSubpath()
                context.fill(rightPage, with: .color(Wafu15Palette.yamabuki))

                // しおりリボン（藍青）
                var ribbon = Path()
                ribbon.move(to: CGPoint(x: w * 0.58, y: h * 0.18))
                ribbon.addLine(to: CGPoint(x: w * 0.70, y: h * 0.18))
                ribbon.addLine(to: CGPoint(x: w * 0.70, y: h * 0.52))
                ribbon.addLine(to: CGPoint(x: w * 0.64, y: h * 0.45))
                ribbon.addLine(to: CGPoint(x: w * 0.58, y: h * 0.52))
                ribbon.closeSubpath()
                context.fill(ribbon, with: .color(Wafu15Palette.ai))

                // ページの縦組み装飾線（白）
                var lines = Path()
                let lineRatios: [CGFloat] = [0.27, 0.35, 0.42]
                for ratio in lineRatios {
                    lines.move(to: CGPoint(x: w * ratio, y: h * 0.41))
                    lines.addLine(to: CGPoint(x: w * ratio, y: h * 0.63))
                }
                context.stroke(lines, with: .color(.white.opacity(0.85)), lineWidth: 1.5)

                // 全体の折り線（墨藍）
                var outline = Path()
                outline.addPath(leftPage)
                outline.addPath(rightPage)
                outline.addPath(ribbon)
                context.stroke(outline, with: .color(Wafu15Palette.ink), lineWidth: 1.5)
            }
        }
        .frame(width: 66, height: 66)
    }
}

// MARK: - Pop Paper Card Modifier

private struct Wafu15PaperCard<Content: View>: View {
    var fill: Color = Wafu15Palette.card
    var shadowColor: Color = Wafu15Palette.ink
    var shadowOffset: CGFloat = 4
    var cornerRadius: CGFloat = 18
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Wafu15Palette.ink, lineWidth: 1.8)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(shadowColor)
                    .offset(x: shadowOffset, y: shadowOffset)
            )
    }
}

// MARK: - 1. Hero Card

private struct Wafu15HeroCard: View {
    var body: some View {
        Wafu15PaperCard(fill: Wafu15Palette.card, shadowColor: Wafu15Palette.ink, shadowOffset: 4) {
            VStack(spacing: 0) {
                // 千代紙 3 種パッチワーク帯
                HStack(spacing: 0) {
                    Wafu15AsanohaPattern(
                        backgroundColor: Wafu15Palette.beni,
                        lineColor: Wafu15Palette.yamabuki.opacity(0.85),
                        radius: 15,
                        lineWidth: 1.05
                    )
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Wafu15Palette.ink)
                        .frame(width: 1.8)

                    Wafu15SeigaihaPattern(
                        backgroundColor: Wafu15Palette.ai,
                        waveColor: Color.white.opacity(0.82),
                        radius: 14,
                        lineWidth: 1.15
                    )
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Wafu15Palette.ink)
                        .frame(width: 1.8)

                    Wafu15IchimatsuPattern(
                        colorA: Wafu15Palette.yamabuki,
                        colorB: Wafu15Palette.matsuba,
                        cellSize: 13
                    )
                    .frame(width: 84)
                }
                .frame(height: 62)

                Rectangle()
                    .fill(Wafu15Palette.ink)
                    .frame(height: 1.8)

                // 本体情報エリア
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center, spacing: 14) {
                        Wafu15AppMark()

                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text("よみび")
                                    .font(.custom("HiraMinProN-W6", size: 30))
                                    .foregroundStyle(Wafu15Palette.ink)
                                    .tracking(2)

                                Text("明朝リーダー")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Wafu15Palette.beni)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Wafu15Palette.beniLight)
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Wafu15Palette.beni.opacity(0.55), lineWidth: 1)
                                    )
                            }

                            Text("ウェブの文章を、本のように読む")
                                .font(.custom("HiraMinProN-W3", size: 13.5))
                                .foregroundStyle(Wafu15Palette.mutedInk)
                                .lineLimit(2)
                        }
                    }

                    // 3つの千代紙切り紙タグ
                    HStack(spacing: 8) {
                        Wafu15TagChip(label: "v1.0", dotColor: Wafu15Palette.beni, bgColor: Wafu15Palette.beniLight)
                        Wafu15TagChip(label: "iOS 18+", dotColor: Wafu15Palette.ai, bgColor: Wafu15Palette.aiLight)
                        Wafu15TagChip(label: "Safari", dotColor: Wafu15Palette.matsuba, bgColor: Wafu15Palette.matsubaLight)
                        Spacer()
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
        }
    }
}

private struct Wafu15TagChip: View {
    let label: String
    let dotColor: Color
    let bgColor: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                .foregroundStyle(Wafu15Palette.ink)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Wafu15Palette.ink.opacity(0.28), lineWidth: 1.2)
        )
    }
}

// MARK: - 2. Status Card

private struct Wafu15StatusCard: View {
    let state: Wafu15Screen.ExtState
    let pulse: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Wafu15PaperCard(fill: Wafu15Palette.card, shadowColor: state.accentColor, shadowOffset: 4) {
                HStack(spacing: 0) {
                    // 左端の七宝柄千代紙タブ
                    Color.clear
                        .frame(width: 50)
                        .overlay {
                            ZStack {
                                Wafu15ShippoPattern(
                                    backgroundColor: state.accentColor,
                                    ringColor: Color.white.opacity(0.45),
                                    diameter: 18,
                                    lineWidth: 1.15
                                )

                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.32))
                                        .frame(width: 24, height: 24)
                                        .scaleEffect(pulse ? 1.25 : 0.85)
                                        .opacity(pulse ? 0.25 : 0.8)

                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 11, height: 11)
                                }
                            }
                        }
                        .clipped()

                    Rectangle()
                        .fill(Wafu15Palette.ink)
                        .frame(width: 1.8)

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 7) {
                                Text(state.badgeText)
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundStyle(state == .checking ? Wafu15Palette.ink : .white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2.5)
                                    .background(
                                        Capsule()
                                            .fill(state.accentColor)
                                    )

                                Text(state.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Wafu15Palette.ink)
                            }

                            Text(state.detail)
                                .font(.system(size: 12.5, weight: .medium))
                                .foregroundStyle(Wafu15Palette.mutedInk)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 4)

                        VStack(spacing: 2) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Wafu15Palette.ink)
                            Text("切替")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundStyle(Wafu15Palette.mutedInk)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(state.tintColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .strokeBorder(Wafu15Palette.ink.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                }
                .frame(minHeight: 74)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("拡張機能の状態: \(state.title)。タップして状態を切り替え")
    }
}

// MARK: - 3. Steps Section

private struct Wafu15StepsSection: View {
    let highlightFloat: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // セクション見出し
            HStack(spacing: 8) {
                Wafu15OrigamiDiamond(colorA: Wafu15Palette.beni, colorB: Wafu15Palette.yamabuki)
                    .frame(width: 16, height: 16)
                Text("はじめの 4 ステップ")
                    .font(.custom("HiraMinProN-W6", size: 17))
                    .foregroundStyle(Wafu15Palette.ink)
                    .tracking(0.8)
                Spacer()
                Text("かんたん設定")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Wafu15Palette.ai)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Wafu15Palette.aiLight))
            }
            .padding(.horizontal, 2)

            // 手順 1〜3
            Wafu15StepRow(
                number: "1",
                patternKind: .ichimatsu,
                accentColor: Wafu15Palette.beni,
                title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
                subtitle: "設定アプリのいちばん下のほう"
            )

            Wafu15StepRow(
                number: "2",
                patternKind: .seigaiha,
                accentColor: Wafu15Palette.ai,
                title: "「よみび」をオンにする",
                subtitle: nil
            )

            Wafu15StepRow(
                number: "3",
                patternKind: .shippo,
                accentColor: Wafu15Palette.matsuba,
                title: "Safari で好きな記事を開く",
                subtitle: nil
            )

            // 手順 4（強調カード）
            Wafu15HighlightStepCard(highlightFloat: highlightFloat)
        }
    }
}

private enum Wafu15ChipPattern {
    case ichimatsu
    case seigaiha
    case shippo
}

private struct Wafu15StepRow: View {
    let number: String
    let patternKind: Wafu15ChipPattern
    let accentColor: Color
    let title: String
    let subtitle: String?

    var body: some View {
        Wafu15PaperCard(fill: Wafu15Palette.card, shadowColor: Wafu15Palette.ink.opacity(0.16), shadowOffset: 3, cornerRadius: 15) {
            HStack(alignment: .center, spacing: 13) {
                // 千代紙模様の番号スクエア
                ZStack {
                    switch patternKind {
                    case .ichimatsu:
                        Wafu15IchimatsuPattern(
                            colorA: Wafu15Palette.beni,
                            colorB: Wafu15Palette.hex(0xC93622),
                            cellSize: 8
                        )
                    case .seigaiha:
                        Wafu15SeigaihaPattern(
                            backgroundColor: Wafu15Palette.ai,
                            waveColor: Color.white.opacity(0.35),
                            radius: 10,
                            lineWidth: 1.0
                        )
                    case .shippo:
                        Wafu15ShippoPattern(
                            backgroundColor: Wafu15Palette.matsuba,
                            ringColor: Color.white.opacity(0.36),
                            diameter: 14,
                            lineWidth: 1.0
                        )
                    }

                    Circle()
                        .fill(Wafu15Palette.card)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .strokeBorder(Wafu15Palette.ink, lineWidth: 1.4)
                        )

                    Text(number)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(accentColor)
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(Wafu15Palette.ink, lineWidth: 1.5)
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(Wafu15Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Wafu15Palette.mutedInk)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 12)
        }
    }
}

private struct Wafu15HighlightStepCard: View {
    let highlightFloat: Bool

    var body: some View {
        Wafu15PaperCard(fill: Wafu15Palette.card, shadowColor: Wafu15Palette.beni, shadowOffset: 4, cornerRadius: 18) {
            VStack(spacing: 0) {
                // 麻の葉の華やかなトップ帯
                ZStack {
                    Wafu15AsanohaPattern(
                        backgroundColor: Wafu15Palette.beni,
                        lineColor: Wafu15Palette.yamabuki.opacity(0.75),
                        radius: 14,
                        lineWidth: 1.0
                    )

                    HStack(spacing: 8) {
                        Text("STEP 4")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(Wafu15Palette.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Wafu15Palette.yamabuki))
                            .overlay(Capsule().strokeBorder(Wafu15Palette.ink, lineWidth: 1.2))

                        Text("ここが仕上げ！")
                            .font(.custom("HiraMinProN-W6", size: 13))
                            .foregroundStyle(.white)
                            .shadow(color: Wafu15Palette.ink.opacity(0.45), radius: 0, x: 1, y: 1)

                        Spacer()

                        // さりげなく上下に揺れる「ぁあ」チップ
                        Text("ぁあ")
                            .font(.custom("HiraMinProN-W6", size: 13))
                            .foregroundStyle(Wafu15Palette.beni)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(Wafu15Palette.ink, lineWidth: 1.3)
                            )
                            .offset(y: highlightFloat ? -2.0 : 1.5)
                    }
                    .padding(.horizontal, 14)
                }
                .frame(height: 40)

                Rectangle()
                    .fill(Wafu15Palette.ink)
                    .frame(height: 1.8)

                // 本文
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Wafu15Palette.yamabuki)
                            .overlay(
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .strokeBorder(Wafu15Palette.ink, lineWidth: 1.6)
                            )
                        Text("4")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Wafu15Palette.ink)
                    }
                    .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("アドレスバーの「ぁあ」から「よみび」を選ぶ")
                            .font(.custom("HiraMinProN-W6", size: 15.5))
                            .foregroundStyle(Wafu15Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundStyle(Wafu15Palette.beni)
                            Text("ここで初めて本文が整う")
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundStyle(Wafu15Palette.beni)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Wafu15Palette.beniLight.opacity(0.45))
            }
        }
    }
}

private struct Wafu15OrigamiDiamond: View {
    let colorA: Color
    let colorB: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var topHalf = Path()
            topHalf.move(to: CGPoint(x: w * 0.5, y: 0))
            topHalf.addLine(to: CGPoint(x: w, y: h * 0.5))
            topHalf.addLine(to: CGPoint(x: 0, y: h * 0.5))
            topHalf.closeSubpath()
            context.fill(topHalf, with: .color(colorA))

            var bottomHalf = Path()
            bottomHalf.move(to: CGPoint(x: 0, y: h * 0.5))
            bottomHalf.addLine(to: CGPoint(x: w, y: h * 0.5))
            bottomHalf.addLine(to: CGPoint(x: w * 0.5, y: h))
            bottomHalf.closeSubpath()
            context.fill(bottomHalf, with: .color(colorB))
        }
    }
}

// MARK: - 4. Notice Card

private struct Wafu15NoticeCard: View {
    var body: some View {
        Wafu15PaperCard(fill: Wafu15Palette.warmTint, shadowColor: Wafu15Palette.yamabuki, shadowOffset: 3, cornerRadius: 15) {
            VStack(spacing: 0) {
                Wafu15YagasuriStrip(
                    baseColor: Wafu15Palette.yamabuki,
                    stripeColor: Wafu15Palette.hex(0xDF980B)
                )
                .frame(height: 8)

                Rectangle()
                    .fill(Wafu15Palette.ink)
                    .frame(height: 1.5)

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Wafu15Palette.yamabuki)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Wafu15Palette.ink, lineWidth: 1.5)
                            )
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Wafu15Palette.ink)
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("サイトごとに許可が要る")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Wafu15Palette.ink)

                        Text("初めて開くサイトでは、拡張を一度許可してください")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(Wafu15Palette.ink.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
            }
        }
    }
}

// MARK: - 5. Primary Button

private struct Wafu15PrimaryButton: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            ZStack {
                Wafu15SeigaihaPattern(
                    backgroundColor: Wafu15Palette.beni,
                    waveColor: Color.white.opacity(0.14),
                    radius: 15,
                    lineWidth: 1.1
                )

                HStack(spacing: 10) {
                    Image(systemName: "safari")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Safari を開く")
                        .font(.custom("HiraMinProN-W6", size: 17))
                        .foregroundStyle(.white)
                        .tracking(1)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Wafu15Palette.ink)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Wafu15Palette.yamabuki))
                        .overlay(Circle().strokeBorder(Wafu15Palette.ink, lineWidth: 1.4))
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Wafu15Palette.ink, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Wafu15Palette.ink)
                    .offset(x: 4, y: 4)
            )
        }
    }
}

// MARK: - 6. Features Card

private struct Wafu15FeaturesCard: View {
    var body: some View {
        Wafu15PaperCard(fill: Wafu15Palette.card, shadowColor: Wafu15Palette.ai, shadowOffset: 3, cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text("よみびのできること")
                        .font(.custom("HiraMinProN-W6", size: 14))
                        .foregroundStyle(Wafu15Palette.ink)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Wafu15Palette.beni).frame(width: 7, height: 7)
                        Circle().fill(Wafu15Palette.ai).frame(width: 7, height: 7)
                        Circle().fill(Wafu15Palette.matsuba).frame(width: 7, height: 7)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(Wafu15Palette.paper.opacity(0.65))

                Rectangle()
                    .fill(Wafu15Palette.subtleLine)
                    .frame(height: 1)

                VStack(spacing: 12) {
                    Wafu15FeatureRow(
                        icon: "text.book.closed.fill",
                        color: Wafu15Palette.beni,
                        text: "本文だけを抜き出して明朝体で組む"
                    )
                    Wafu15FeatureRow(
                        icon: "textformat.size",
                        color: Wafu15Palette.ai,
                        text: "行間と文字の大きさを端末に合わせる"
                    )
                    Wafu15FeatureRow(
                        icon: "bookmark.fill",
                        color: Wafu15Palette.matsuba,
                        text: "読んだ位置を覚えておく"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }
}

private struct Wafu15FeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(Wafu15Palette.ink, lineWidth: 1.3)
                    )
                Image(systemName: icon)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 32, height: 32)

            Text(text)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(Wafu15Palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - 7. Footer

private struct Wafu15Footer: View {
    var body: some View {
        VStack(spacing: 10) {
            // 千代紙 4 色ドットリボン
            HStack(spacing: 6) {
                ForEach(0..<12, id: \.self) { index in
                    let palette = [
                        Wafu15Palette.beni,
                        Wafu15Palette.yamabuki,
                        Wafu15Palette.matsuba,
                        Wafu15Palette.ai
                    ]
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(palette[index % palette.count])
                        .frame(width: 10, height: 5)
                }
            }

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Wafu15Palette.mutedInk)
        }
        .padding(.top, 4)
    }
}

#Preview {
    Wafu15Screen()
}
