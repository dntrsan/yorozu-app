import SwiftUI

// MARK: - Wafu 11: 京モダン・組子と白木

private extension Color {
    init(wafu11Hex: UInt32, alpha: Double = 1.0) {
        let r = Double((wafu11Hex >> 16) & 0xFF) / 255.0
        let g = Double((wafu11Hex >> 8) & 0xFF) / 255.0
        let b = Double(wafu11Hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum Wafu11Palette {
    static let bgWashi          = Color(wafu11Hex: 0xF6F2E9) // 白練
    static let surfaceHinoki    = Color(wafu11Hex: 0xFCF9F2) // 生成白
    static let surfaceWoodTint  = Color(wafu11Hex: 0xEFE8D8) // 薄檜
    static let surfaceHighlight = Color(wafu11Hex: 0xEDF3EE) // 白緑淡
    static let kumikoLine       = Color(wafu11Hex: 0xD8CBB3) // 白木桟
    static let kumikoStrong     = Color(wafu11Hex: 0xBCA98A) // 檜皮桟
    static let woodGrain        = Color(wafu11Hex: 0xE6DCC8) // 木目淡
    static let inkPrimary       = Color(wafu11Hex: 0x231F1B) // 墨色
    static let inkSecondary     = Color(wafu11Hex: 0x6B6257) // 鈍茶
    static let inkMuted         = Color(wafu11Hex: 0x948A7D) // 灰茶
    static let accentPine       = Color(wafu11Hex: 0x2A4B3E) // 千歳緑
    static let accentPineSoft   = Color(wafu11Hex: 0xDCE6E0) // 若松淡
    static let noticeOchre      = Color(wafu11Hex: 0x9C6A2D) // 黄土
    static let noticeSurface    = Color(wafu11Hex: 0xF8F1E3) // 鳥の子淡
    static let statusOff        = Color(wafu11Hex: 0x8A8277) // 利休鼠
}

private enum Wafu11Font {
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

private struct Wafu11StepItem: Identifiable {
    let id: Int
    let kanji: String
    let numberLabel: String
    let title: String
    let note: String?
    let isHighlighted: Bool
}

private struct Wafu11FeatureItem: Identifiable {
    let id: Int
    let symbol: String
    let text: String
}

private enum Wafu11Content {
    static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!
    static let tags = ["v1.0", "iOS 18+", "Safari"]

    static let steps: [Wafu11StepItem] = [
        Wafu11StepItem(
            id: 1,
            kanji: "一",
            numberLabel: "01",
            title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
            note: "設定アプリのいちばん下のほう",
            isHighlighted: false
        ),
        Wafu11StepItem(
            id: 2,
            kanji: "二",
            numberLabel: "02",
            title: "「よみび」をオンにする",
            note: nil,
            isHighlighted: false
        ),
        Wafu11StepItem(
            id: 3,
            kanji: "三",
            numberLabel: "03",
            title: "Safari で好きな記事を開く",
            note: nil,
            isHighlighted: false
        ),
        Wafu11StepItem(
            id: 4,
            kanji: "四",
            numberLabel: "04",
            title: "アドレスバーの「ぁあ」から「よみび」を選ぶ",
            note: "ここで初めて本文が整う",
            isHighlighted: true
        )
    ]

    static let features: [Wafu11FeatureItem] = [
        Wafu11FeatureItem(id: 1, symbol: "text.book.closed", text: "本文だけを抜き出して明朝体で組む"),
        Wafu11FeatureItem(id: 2, symbol: "textformat.size", text: "行間と文字の大きさを端末に合わせる"),
        Wafu11FeatureItem(id: 3, symbol: "bookmark", text: "読んだ位置を覚えておく")
    ]
}

// MARK: - Main Screen

struct Wafu11Screen: View {
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
            case .on: return "Safari で記事を整える準備ができています"
            case .off: return "設定アプリから「よみび」を有効にしてください"
            case .checking: return "Safari 機能拡張の状態を確かめています…"
            }
        }

        var badgeText: String {
            switch self {
            case .on: return "有効"
            case .off: return "停止"
            case .checking: return "確認"
            }
        }

        var accentColor: Color {
            switch self {
            case .on: return Wafu11Palette.accentPine
            case .off: return Wafu11Palette.statusOff
            case .checking: return Wafu11Palette.noticeOchre
            }
        }
    }

    @State private var extState: ExtState = .on
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            Wafu11HinokiBackground()
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    transomBand
                    heroSection
                    statusSection
                    stepsSection
                    noticeSection
                    primaryActionSection
                    featuresSection
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    // MARK: - 1. 欄間・麻の葉組子帯

    private var transomBand: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Wafu11Palette.kumikoStrong)
                .frame(height: 1)

            Wafu11AsanohaBand()
                .frame(height: 36)
                .background(Wafu11Palette.surfaceHinoki.opacity(0.65))

            Rectangle()
                .fill(Wafu11Palette.kumikoStrong)
                .frame(height: 1)
        }
    }

    // MARK: - 2. ヒーロー（端正なグリッド）

    private var heroSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                Wafu11AppMark()
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("よみび")
                            .font(Wafu11Font.minchoSemiBold(28))
                            .tracking(4)
                            .foregroundStyle(Wafu11Palette.inkPrimary)

                        Text("読日")
                            .font(Wafu11Font.minchoRegular(11))
                            .tracking(2)
                            .foregroundStyle(Wafu11Palette.inkMuted)
                    }

                    Text("ウェブの文章を、本のように読む")
                        .font(Wafu11Font.minchoRegular(13))
                        .tracking(0.5)
                        .foregroundStyle(Wafu11Palette.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)

            Rectangle()
                .fill(Wafu11Palette.kumikoLine)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(Array(Wafu11Content.tags.enumerated()), id: \.offset) { index, tag in
                    if index > 0 {
                        Rectangle()
                            .fill(Wafu11Palette.kumikoLine)
                            .frame(width: 1, height: 32)
                    }
                    Text(tag)
                        .font(Wafu11Font.gothic(11, weight: .medium))
                        .tracking(1.0)
                        .foregroundStyle(Wafu11Palette.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            .background(Wafu11Palette.surfaceWoodTint.opacity(0.45))
        }
        .background(Wafu11Palette.surfaceHinoki)
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    // MARK: - 3. 状態表示カード

    private var statusSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                extState.next()
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(extState.accentColor.opacity(isPulsing ? 0.24 : 0.08))
                        .frame(width: 22, height: 22)
                        .scaleEffect(isPulsing ? 1.12 : 0.86)

                    Circle()
                        .fill(extState.accentColor)
                        .frame(width: 8, height: 8)
                }
                .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(extState.label)
                            .font(Wafu11Font.minchoSemiBold(14.5))
                            .tracking(0.6)
                            .foregroundStyle(Wafu11Palette.inkPrimary)

                        Text(extState.badgeText)
                            .font(Wafu11Font.gothic(10, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(extState.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(extState.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(extState.accentColor.opacity(0.35), lineWidth: 0.75)
                            )
                    }

                    Text(extState.detail)
                        .font(Wafu11Font.gothic(11.5))
                        .foregroundStyle(Wafu11Palette.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                VStack(spacing: 2) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Wafu11Palette.inkMuted)
                    Text("切替")
                        .font(Wafu11Font.gothic(9.5, weight: .medium))
                        .foregroundStyle(Wafu11Palette.inkMuted)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Wafu11Palette.surfaceWoodTint.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 0.75)
                )
            }
            .padding(.leading, 17.5)
            .padding(.trailing, 14)
            .padding(.vertical, 14)
            .background(Wafu11Palette.surfaceHinoki)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(extState.accentColor)
                    .frame(width: 3.5)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("機能拡張の状態を切り替える")
    }

    // MARK: - 4. 手順 4 つ（端正なグリッド表）

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Wafu11SectionHeader(title: "はじめの手順")

            VStack(spacing: 0) {
                ForEach(Array(Wafu11Content.steps.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Rectangle()
                            .fill(item.isHighlighted ? Wafu11Palette.accentPine.opacity(0.35) : Wafu11Palette.kumikoLine)
                            .frame(height: 1)
                    }
                    stepRow(item)
                }
            }
            .background(Wafu11Palette.surfaceHinoki)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }

    private func stepRow(_ item: Wafu11StepItem) -> some View {
        HStack(spacing: 0) {
            if item.isHighlighted {
                Rectangle()
                    .fill(Wafu11Palette.accentPine)
                    .frame(width: 3.5)
            }

            VStack(spacing: 2) {
                Text(item.kanji)
                    .font(Wafu11Font.minchoSemiBold(16))
                    .foregroundStyle(item.isHighlighted ? Wafu11Palette.accentPine : Wafu11Palette.inkPrimary)

                Text(item.numberLabel)
                    .font(Wafu11Font.gothic(9.5, weight: .medium))
                    .tracking(0.6)
                    .foregroundStyle(item.isHighlighted ? Wafu11Palette.accentPine.opacity(0.8) : Wafu11Palette.inkMuted)
            }
            .frame(width: item.isHighlighted ? 44.5 : 48)
            .frame(maxHeight: .infinity)
            .padding(.vertical, 14)

            Rectangle()
                .fill(item.isHighlighted ? Wafu11Palette.accentPine.opacity(0.25) : Wafu11Palette.kumikoLine)
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 5) {
                if item.isHighlighted {
                    Text("ここで適用")
                        .font(Wafu11Font.gothic(10, weight: .semibold))
                        .tracking(1.0)
                        .foregroundStyle(Wafu11Palette.accentPine)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Wafu11Palette.accentPineSoft)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(Wafu11Palette.accentPine.opacity(0.35), lineWidth: 0.75)
                        )
                }

                Text(item.title)
                    .font(item.isHighlighted ? Wafu11Font.minchoSemiBold(14) : Wafu11Font.gothic(13.5, weight: .medium))
                    .foregroundStyle(Wafu11Palette.inkPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if let note = item.note {
                    Text(note)
                        .font(Wafu11Font.gothic(11.5))
                        .foregroundStyle(item.isHighlighted ? Wafu11Palette.accentPine : Wafu11Palette.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(item.isHighlighted ? Wafu11Palette.surfaceHighlight : Wafu11Palette.surfaceHinoki)
    }

    // MARK: - 5. 注意カード

    private var noticeSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Wafu11Palette.noticeOchre)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("サイトごとに許可が要る")
                    .font(Wafu11Font.minchoSemiBold(13.5))
                    .tracking(0.5)
                    .foregroundStyle(Wafu11Palette.inkPrimary)

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(Wafu11Font.gothic(12))
                    .foregroundStyle(Wafu11Palette.inkSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.leading, 17.5)
        .padding(.trailing, 14)
        .padding(.vertical, 14)
        .background(Wafu11Palette.noticeSurface)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Wafu11Palette.noticeOchre)
                .frame(width: 3.5)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    // MARK: - 6. 主ボタン

    private var primaryActionSection: some View {
        Link(destination: Wafu11Content.safariURL) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Wafu11Palette.accentPine)

                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(Wafu11Palette.kumikoLine.opacity(0.42), lineWidth: 0.75)
                    .padding(4)

                HStack(spacing: 10) {
                    Text("Safari を開く")
                        .font(Wafu11Font.minchoSemiBold(15.5))
                        .tracking(2.0)
                        .foregroundStyle(Wafu11Palette.surfaceHinoki)

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Wafu11Palette.kumikoLine)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 7. 説明 3 行

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Wafu11SectionHeader(title: "よみびの仕立て")

            VStack(spacing: 0) {
                ForEach(Array(Wafu11Content.features.enumerated()), id: \.element.id) { index, feature in
                    if index > 0 {
                        Rectangle()
                            .fill(Wafu11Palette.kumikoLine)
                            .frame(height: 1)
                    }

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Wafu11Palette.surfaceWoodTint.opacity(0.75))
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 0.75)
                            Image(systemName: feature.symbol)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Wafu11Palette.accentPine)
                        }
                        .frame(width: 32, height: 32)

                        Text(feature.text)
                            .font(Wafu11Font.minchoRegular(13.5))
                            .tracking(0.3)
                            .foregroundStyle(Wafu11Palette.inkPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
            .background(Wafu11Palette.surfaceHinoki)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Wafu11Palette.kumikoLine, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }

    // MARK: - 8. 足元

    private var footerSection: some View {
        VStack(spacing: 12) {
            Wafu11LatticeDivider()
                .frame(height: 10)
                .padding(.top, 4)

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(Wafu11Font.minchoRegular(11))
                .tracking(0.8)
                .foregroundStyle(Wafu11Palette.inkMuted)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Decorative & Graphic Components

private struct Wafu11SectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Wafu11Palette.accentPine)
                .frame(width: 6, height: 6)
                .rotationEffect(.degrees(45))

            Text(title)
                .font(Wafu11Font.minchoSemiBold(12.5))
                .tracking(2.0)
                .foregroundStyle(Wafu11Palette.inkSecondary)

            Rectangle()
                .fill(Wafu11Palette.kumikoLine)
                .frame(height: 1)
        }
    }
}

private struct Wafu11HinokiBackground: View {
    var body: some View {
        ZStack {
            Wafu11Palette.bgWashi

            Canvas { context, size in
                let grainStyle = StrokeStyle(lineWidth: 0.6)
                let spacing: CGFloat = 14
                var x: CGFloat = 0
                var index = 0

                while x <= size.width {
                    let opacity: Double = (index % 3 == 0) ? 0.34 : 0.16
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: 0))
                    line.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(
                        line,
                        with: .color(Wafu11Palette.woodGrain.opacity(opacity)),
                        style: grainStyle
                    )
                    x += spacing
                    index += 1
                }
            }
        }
    }
}

private struct Wafu11AsanohaBand: View {
    var body: some View {
        Canvas { context, size in
            let radius: CGFloat = 18
            let dx = radius * CGFloat(sqrt(3.0))
            let dy = radius * 1.5
            let mainStyle = StrokeStyle(lineWidth: 0.85, lineCap: .round, lineJoin: .round)
            let fineStyle = StrokeStyle(lineWidth: 0.55, lineCap: .round, lineJoin: .round)

            var mainPath = Path()
            var finePath = Path()

            let rows = Int(ceil(size.height / dy)) + 2
            let cols = Int(ceil(size.width / dx)) + 2

            for row in -1...rows {
                let xOffset: CGFloat = (row % 2 == 0) ? 0 : dx / 2
                let cy = CGFloat(row) * dy

                for col in -1...cols {
                    let cx = CGFloat(col) * dx + xOffset
                    let center = CGPoint(x: cx, y: cy)

                    var vertices: [CGPoint] = []
                    for i in 0..<6 {
                        let angle: CGFloat = CGFloat(i) * (CGFloat.pi / 3.0) - (CGFloat.pi / 2.0)
                        let vx = cx + radius * cos(angle)
                        let vy = cy + radius * sin(angle)
                        vertices.append(CGPoint(x: vx, y: vy))
                    }

                    for i in 0..<6 {
                        let v1 = vertices[i]
                        let v2 = vertices[(i + 1) % 6]

                        mainPath.move(to: v1)
                        mainPath.addLine(to: v2)

                        mainPath.move(to: center)
                        mainPath.addLine(to: v1)

                        let gx = (cx + v1.x + v2.x) / 3.0
                        let gy = (cy + v1.y + v2.y) / 3.0
                        let centroid = CGPoint(x: gx, y: gy)

                        finePath.move(to: centroid)
                        finePath.addLine(to: center)
                        finePath.move(to: centroid)
                        finePath.addLine(to: v1)
                        finePath.move(to: centroid)
                        finePath.addLine(to: v2)
                    }
                }
            }

            context.stroke(finePath, with: .color(Wafu11Palette.kumikoLine.opacity(0.65)), style: fineStyle)
            context.stroke(mainPath, with: .color(Wafu11Palette.kumikoStrong.opacity(0.85)), style: mainStyle)
        }
        .clipped()
    }
}

private struct Wafu11AppMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let outerRect = CGRect(x: 0.5, y: 0.5, width: w - 1, height: h - 1)
            let innerRect = CGRect(x: 5, y: 5, width: w - 10, height: h - 10)

            // 白木額の背景
            context.fill(
                Path(roundedRect: outerRect, cornerRadius: 3),
                with: .color(Wafu11Palette.surfaceWoodTint)
            )

            // 内枠（千歳緑の漆喰面）
            context.fill(
                Path(roundedRect: innerRect, cornerRadius: 2),
                with: .color(Wafu11Palette.accentPine)
            )

            // 外枠の檜桟
            context.stroke(
                Path(roundedRect: outerRect, cornerRadius: 3),
                with: .color(Wafu11Palette.kumikoStrong),
                style: StrokeStyle(lineWidth: 1)
            )

            // 背景の淡い組子菱
            let cx = w / 2
            let cy = h / 2
            var diamond = Path()
            diamond.move(to: CGPoint(x: cx, y: 9))
            diamond.addLine(to: CGPoint(x: w - 9, y: cy))
            diamond.addLine(to: CGPoint(x: cx, y: h - 9))
            diamond.addLine(to: CGPoint(x: 9, y: cy))
            diamond.closeSubpath()
            context.stroke(
                diamond,
                with: .color(Wafu11Palette.kumikoLine.opacity(0.32)),
                style: StrokeStyle(lineWidth: 0.8)
            )

            // 見開きの本（幾何学的な白木の頁）
            var leftPage = Path()
            leftPage.move(to: CGPoint(x: cx - 1.5, y: 19))
            leftPage.addLine(to: CGPoint(x: 15, y: 17))
            leftPage.addLine(to: CGPoint(x: 15, y: h - 17))
            leftPage.addLine(to: CGPoint(x: cx - 1.5, y: h - 19))
            leftPage.closeSubpath()

            var rightPage = Path()
            rightPage.move(to: CGPoint(x: cx + 1.5, y: 19))
            rightPage.addLine(to: CGPoint(x: w - 15, y: 17))
            rightPage.addLine(to: CGPoint(x: w - 15, y: h - 17))
            rightPage.addLine(to: CGPoint(x: cx + 1.5, y: h - 19))
            rightPage.closeSubpath()

            context.fill(leftPage, with: .color(Wafu11Palette.surfaceHinoki))
            context.fill(rightPage, with: .color(Wafu11Palette.surfaceHinoki))

            // 縦書きの本文を示す極細の墨線（右頁・左頁）
            var textLines = Path()
            let rightXs: [CGFloat] = [cx + 6.5, cx + 11.0]
            for rx in rightXs {
                textLines.move(to: CGPoint(x: rx, y: 23))
                textLines.addLine(to: CGPoint(x: rx, y: h - 23))
            }
            let leftXs: [CGFloat] = [cx - 6.5, cx - 11.0]
            for lx in leftXs {
                textLines.move(to: CGPoint(x: lx, y: 23))
                textLines.addLine(to: CGPoint(x: lx, y: h - 25))
            }
            context.stroke(
                textLines,
                with: .color(Wafu11Palette.accentPine.opacity(0.55)),
                style: StrokeStyle(lineWidth: 1.1, lineCap: .round)
            )

            // 綴じ目（中央の縦桟）
            var spine = Path()
            spine.move(to: CGPoint(x: cx, y: 16))
            spine.addLine(to: CGPoint(x: cx, y: h - 16))
            context.stroke(
                spine,
                with: .color(Wafu11Palette.kumikoLine),
                style: StrokeStyle(lineWidth: 1.0)
            )
        }
    }
}

private struct Wafu11LatticeDivider: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var path = Path()

            path.move(to: CGPoint(x: 0, y: 0.5))
            path.addLine(to: CGPoint(x: w, y: 0.5))
            path.move(to: CGPoint(x: 0, y: h - 0.5))
            path.addLine(to: CGPoint(x: w, y: h - 0.5))

            let step: CGFloat = 12
            var x: CGFloat = 0
            while x <= w {
                path.move(to: CGPoint(x: x, y: 0.5))
                path.addLine(to: CGPoint(x: x, y: h - 0.5))
                x += step
            }

            context.stroke(
                path,
                with: .color(Wafu11Palette.kumikoLine.opacity(0.85)),
                style: StrokeStyle(lineWidth: 0.75)
            )
        }
    }
}

#Preview {
    Wafu11Screen()
}
