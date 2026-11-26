import SwiftUI

// MARK: - Palette

private enum Wafu16Palette {
    static let paper = hex(0xFBFAF8)        // 胡粉白（地色）
    static let paperSub = hex(0xF4F2ED)     // 淡灰紙（但し書き・見出し帯）
    static let ink = hex(0x141414)          // 墨黒（主文字・家紋・罫線）
    static let mutedInk = hex(0x63605B)     // 薄墨（補足文字）
    static let rule = hex(0xD8D4CB)         // 細罫灰（区切り線）
    static let shu = hex(0xC92E23)          // 朱肉（判子・強調）
    static let shuTint = hex(0xFAF0EE)      // 淡朱（強調欄の下地）

    static func hex(_ value: UInt32, alpha: Double = 1.0) -> Color {
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Main Screen

struct Wafu16Screen: View {
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

        var stampKanji: String {
            switch self {
            case .on: return "済"
            case .off: return "未"
            case .checking: return "確"
            }
        }

        var stampSub: String {
            switch self {
            case .on: return "稼働"
            case .off: return "停止"
            case .checking: return "照会"
            }
        }

        var title: String {
            switch self {
            case .on: return "拡張はオンです"
            case .off: return "拡張はオフです"
            case .checking: return "状態を確認中"
            }
        }

        var detail: String {
            switch self {
            case .on: return "Safari で本文を明朝体に整えられます"
            case .off: return "下の四工程に沿って設定を有効にしてください"
            case .checking: return "Safari の拡張設定を確かめています…"
            }
        }
    }

    @State private var extState: ExtState = .on
    @State private var stampBreath: Bool = false

    private static let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        ZStack {
            Wafu16Palette.paper
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Wafu16TopDoubleRule()

                    Wafu16HeroSection()

                    Wafu16StatusStampCard(
                        state: extState,
                        breath: stampBreath,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.24)) {
                                extState = extState.next
                            }
                        }
                    )

                    Wafu16StepsSection()

                    Wafu16NoticeBox()

                    Wafu16PrimaryButton(url: Self.safariURL)

                    Wafu16FeaturesSection()

                    Wafu16Footer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 36)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                stampBreath = true
            }
        }
    }
}

// MARK: - Traditional Rules & Ornaments

/// 子持ち罫（太線＋細線の和風二重罫線）
private struct Wafu16TopDoubleRule: View {
    var inverted: Bool = false

    var body: some View {
        VStack(spacing: 3) {
            Rectangle()
                .fill(Wafu16Palette.ink)
                .frame(height: inverted ? 0.75 : 2.0)
            Rectangle()
                .fill(Wafu16Palette.ink)
                .frame(height: inverted ? 2.0 : 0.75)
        }
    }
}

/// 極小の四つ目菱（見出し飾り）
private struct Wafu16YotsumeDiamond: View {
    var color: Color = Wafu16Palette.ink

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2
            let d = min(w, h) * 0.22
            let offsets: [(CGFloat, CGFloat)] = [
                (0, -d * 1.15),
                (d * 1.15, 0),
                (0, d * 1.15),
                (-d * 1.15, 0)
            ]
            for (ox, oy) in offsets {
                var p = Path()
                p.move(to: CGPoint(x: cx + ox, y: cy + oy - d))
                p.addLine(to: CGPoint(x: cx + ox + d, y: cy + oy))
                p.addLine(to: CGPoint(x: cx + ox, y: cy + oy + d))
                p.addLine(to: CGPoint(x: cx + ox - d, y: cy + oy))
                p.closeSubpath()
                context.fill(p, with: .color(color))
            }
        }
    }
}

// MARK: - App Mark (Kamon: Maru ni Hiraki-sho)

/// 家紋風幾何学マーク「丸に開き書」
private struct Wafu16KamonMark: View {
    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let cx = size.width / 2
            let cy = size.height / 2
            let center = CGPoint(x: cx, y: cy)

            // 外輪（太い家紋リング）
            let outerR = s * 0.455
            let outerRect = CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2, height: outerR * 2)
            context.stroke(
                Path(ellipseIn: outerRect),
                with: .color(Wafu16Palette.ink),
                lineWidth: s * 0.068
            )

            // 内輪（繊細な内円）
            let innerR = s * 0.372
            let innerRect = CGRect(x: cx - innerR, y: cy - innerR, width: innerR * 2, height: innerR * 2)
            context.stroke(
                Path(ellipseIn: innerRect),
                with: .color(Wafu16Palette.ink),
                lineWidth: s * 0.015
            )

            // 幾何学の「開いた本」左右の頁（黒ベタ）
            var leftPage = Path()
            leftPage.move(to: CGPoint(x: cx - s * 0.025, y: cy - s * 0.14))
            leftPage.addLine(to: CGPoint(x: cx - s * 0.255, y: cy - s * 0.215))
            leftPage.addLine(to: CGPoint(x: cx - s * 0.255, y: cy + s * 0.165))
            leftPage.addLine(to: CGPoint(x: cx - s * 0.025, y: cy + s * 0.235))
            leftPage.closeSubpath()
            context.fill(leftPage, with: .color(Wafu16Palette.ink))

            var rightPage = Path()
            rightPage.move(to: CGPoint(x: cx + s * 0.025, y: cy - s * 0.14))
            rightPage.addLine(to: CGPoint(x: cx + s * 0.255, y: cy - s * 0.215))
            rightPage.addLine(to: CGPoint(x: cx + s * 0.255, y: cy + s * 0.165))
            rightPage.addLine(to: CGPoint(x: cx + s * 0.025, y: cy + s * 0.235))
            rightPage.closeSubpath()
            context.fill(rightPage, with: .color(Wafu16Palette.ink))

            // 頁に彫り抜いた縦書きの三本線（白抜き）
            var cuts = Path()
            let lineRatios: [CGFloat] = [0.09, 0.145, 0.20]
            for ratio in lineRatios {
                let lx = cx - s * ratio
                let rx = cx + s * ratio
                let topOffset = s * (0.095 + (ratio - 0.09) * 0.45)
                let botOffset = s * (0.14 - (ratio - 0.09) * 0.35)
                cuts.move(to: CGPoint(x: lx, y: cy - topOffset))
                cuts.addLine(to: CGPoint(x: lx, y: cy + botOffset))
                cuts.move(to: CGPoint(x: rx, y: cy - topOffset))
                cuts.addLine(to: CGPoint(x: rx, y: cy + botOffset))
            }
            context.stroke(cuts, with: .color(Wafu16Palette.paper), lineWidth: s * 0.022)

            // 天頂の菱（よみびの「日」を象徴する家紋の要）
            let dy = cy - s * 0.245
            let dr = s * 0.055
            var diamond = Path()
            diamond.move(to: CGPoint(x: center.x, y: dy - dr))
            diamond.addLine(to: CGPoint(x: center.x + dr, y: dy))
            diamond.addLine(to: CGPoint(x: center.x, y: dy + dr))
            diamond.addLine(to: CGPoint(x: center.x - dr, y: dy))
            diamond.closeSubpath()
            context.fill(diamond, with: .color(Wafu16Palette.ink))

            // 下部の細い台座菱（安定感）
            let by = cy + s * 0.285
            let br = s * 0.032
            var baseDiamond = Path()
            baseDiamond.move(to: CGPoint(x: center.x, y: by - br))
            baseDiamond.addLine(to: CGPoint(x: center.x + br * 1.4, y: by))
            baseDiamond.addLine(to: CGPoint(x: center.x, y: by + br))
            baseDiamond.addLine(to: CGPoint(x: center.x - br * 1.4, y: by))
            baseDiamond.closeSubpath()
            context.fill(baseDiamond, with: .color(Wafu16Palette.ink))
        }
        .frame(width: 86, height: 86)
    }
}

/// 判子のかすれ質感を再現するオーバーレイ（決定論的な白抜き点）
private struct Wafu16HankoTextureOverlay: View {
    var paperColor: Color = Wafu16Palette.paper

    var body: some View {
        Canvas { context, size in
            let specks: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0.14, 0.20, 2.2, 1.1),
                (0.82, 0.16, 1.8, 1.3),
                (0.26, 0.78, 2.6, 1.0),
                (0.75, 0.84, 1.7, 1.4),
                (0.91, 0.48, 2.0, 1.0),
                (0.08, 0.54, 1.9, 1.2),
                (0.50, 0.06, 2.4, 0.9),
                (0.46, 0.93, 2.1, 1.0)
            ]
            for (rx, ry, rw, rh) in specks {
                let rect = CGRect(
                    x: size.width * rx,
                    y: size.height * ry,
                    width: rw,
                    height: rh
                )
                context.fill(Path(ellipseIn: rect), with: .color(paperColor.opacity(0.65)))
            }
        }
        .allowsHitTesting(false)
    }
}

/// 小さな朱肉の角印落款
private struct Wafu16SmallSquareHanko: View {
    let text: String
    var size: CGFloat = 24
    var angle: Double = -5

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                .fill(Wafu16Palette.shu)

            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .strokeBorder(Wafu16Palette.paper.opacity(0.88), lineWidth: 1.1)
                .padding(2.2)

            Text(text)
                .font(.custom("HiraMinProN-W6", size: size * 0.52))
                .foregroundStyle(Wafu16Palette.paper)

            Wafu16HankoTextureOverlay()
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(angle))
    }
}

// MARK: - 1. Hero Section

private struct Wafu16HeroSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // 家紋マーク＋右下に小さな朱肉落款
            ZStack(alignment: .bottomTrailing) {
                Wafu16KamonMark()
                    .padding(6)

                Wafu16SmallSquareHanko(text: "読", size: 24, angle: -7)
                    .offset(x: 4, y: 2)
            }

            VStack(spacing: 7) {
                Text("よみび")
                    .font(.custom("HiraMinProN-W6", size: 32))
                    .foregroundStyle(Wafu16Palette.ink)
                    .tracking(7)
                    .padding(.leading, 7)

                Text("ウェブの文章を、本のように読む")
                    .font(.custom("HiraMinProN-W3", size: 13.5))
                    .foregroundStyle(Wafu16Palette.mutedInk)
                    .tracking(1.2)
            }

            // 端正な3連タグ（墨黒の細罫枠）
            HStack(spacing: 0) {
                Wafu16MetaTag(label: "v1.0")
                Rectangle()
                    .fill(Wafu16Palette.ink)
                    .frame(width: 1, height: 24)
                Wafu16MetaTag(label: "iOS 18+")
                Rectangle()
                    .fill(Wafu16Palette.ink)
                    .frame(width: 1, height: 24)
                Wafu16MetaTag(label: "Safari")
            }
            .overlay(
                Rectangle()
                    .strokeBorder(Wafu16Palette.ink, lineWidth: 1)
            )
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Wafu16MetaTag: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(Wafu16Palette.ink)
            .tracking(0.6)
            .padding(.horizontal, 14)
            .frame(height: 24)
    }
}

// MARK: - 2. Status Stamp Card

private struct Wafu16StatusStampCard: View {
    let state: Wafu16Screen.ExtState
    let breath: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("拡張の状態")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundStyle(Wafu16Palette.mutedInk)
                            .tracking(1.5)

                        Text("／")
                            .font(.system(size: 10.5))
                            .foregroundStyle(Wafu16Palette.rule)

                        Text("タップで切替")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(Wafu16Palette.mutedInk)
                    }

                    Text(state.title)
                        .font(.custom("HiraMinProN-W6", size: 17))
                        .foregroundStyle(Wafu16Palette.ink)
                        .tracking(0.8)

                    Text(state.detail)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Wafu16Palette.mutedInk)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                // 朱肉の丸判子（オン＝朱肉押印、オフ＝墨破線未押印、確認中＝朱細線）
                Wafu16RoundStatusHanko(state: state, breath: breath)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Wafu16Palette.paper)
            .overlay(
                Rectangle()
                    .strokeBorder(Wafu16Palette.ink, lineWidth: 1.2)
            )
            .overlay(
                Rectangle()
                    .strokeBorder(Wafu16Palette.ink.opacity(0.25), lineWidth: 0.6)
                    .padding(3.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("拡張機能の状態: \(state.title)。タップして状態を切り替え")
    }
}

private struct Wafu16RoundStatusHanko: View {
    let state: Wafu16Screen.ExtState
    let breath: Bool

    var body: some View {
        ZStack {
            if state == .on {
                // 静かに呼吸する朱の余韻リング（控えめなアニメーション1か所）
                Circle()
                    .stroke(Wafu16Palette.shu.opacity(breath ? 0.08 : 0.34), lineWidth: 1.2)
                    .frame(width: 64, height: 64)
                    .scaleEffect(breath ? 1.09 : 0.98)
            }

            ZStack {
                if state == .on {
                    Circle()
                        .fill(Wafu16Palette.shu.opacity(0.06))
                    Circle()
                        .strokeBorder(Wafu16Palette.shu, lineWidth: 2.2)
                    Circle()
                        .strokeBorder(Wafu16Palette.shu, lineWidth: 0.8)
                        .padding(3.5)
                } else if state == .off {
                    Circle()
                        .stroke(
                            Wafu16Palette.mutedInk.opacity(0.75),
                            style: StrokeStyle(lineWidth: 1.4, dash: [4, 3])
                        )
                } else {
                    Circle()
                        .strokeBorder(Wafu16Palette.shu.opacity(0.75), lineWidth: 1.6)
                    Circle()
                        .stroke(
                            Wafu16Palette.shu.opacity(0.45),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                        )
                        .padding(4)
                }

                VStack(spacing: 1) {
                    Text(state.stampKanji)
                        .font(.custom("HiraMinProN-W6", size: 22))
                        .foregroundStyle(state == .off ? Wafu16Palette.mutedInk : Wafu16Palette.shu)
                    Text(state.stampSub)
                        .font(.custom("HiraMinProN-W3", size: 9.5))
                        .foregroundStyle(state == .off ? Wafu16Palette.mutedInk : Wafu16Palette.shu)
                        .tracking(1.5)
                }

                if state == .on {
                    Wafu16HankoTextureOverlay()
                }
            }
            .frame(width: 58, height: 58)
            .rotationEffect(.degrees(state == .on ? -6 : 0))
        }
        .frame(width: 64, height: 64)
    }
}

// MARK: - 3. Steps Section

private struct Wafu16StepsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // セクション見出し
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Wafu16YotsumeDiamond()
                        .frame(width: 14, height: 14)
                    Text("設定のてびき")
                        .font(.custom("HiraMinProN-W6", size: 16.5))
                        .foregroundStyle(Wafu16Palette.ink)
                        .tracking(2.5)
                    Spacer()
                    Text("全四工程")
                        .font(.custom("HiraMinProN-W3", size: 11.5))
                        .foregroundStyle(Wafu16Palette.mutedInk)
                        .tracking(1.5)
                }

                Rectangle()
                    .fill(Wafu16Palette.ink)
                    .frame(height: 1.5)
            }

            // 手順 1〜3：端正な罫線表
            VStack(spacing: 0) {
                Wafu16StepTableRow(
                    kanji: "壱",
                    num: "01",
                    title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
                    subtitle: "設定アプリのいちばん下のほう"
                )
                Rectangle().fill(Wafu16Palette.rule).frame(height: 1)

                Wafu16StepTableRow(
                    kanji: "弐",
                    num: "02",
                    title: "「よみび」をオンにする",
                    subtitle: nil
                )
                Rectangle().fill(Wafu16Palette.rule).frame(height: 1)

                Wafu16StepTableRow(
                    kanji: "参",
                    num: "03",
                    title: "Safari で好きな記事を開く",
                    subtitle: nil
                )
            }
            .background(Wafu16Palette.paper)
            .overlay(
                Rectangle()
                    .strokeBorder(Wafu16Palette.ink, lineWidth: 1)
            )

            // 手順 4（朱肉の角印＋朱帯で強調）
            Wafu16HighlightStep4Card()
        }
    }
}

private struct Wafu16StepTableRow: View {
    let kanji: String
    let num: String
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(kanji)
                    .font(.custom("HiraMinProN-W6", size: 17))
                    .foregroundStyle(Wafu16Palette.ink)
                Text(num)
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Wafu16Palette.mutedInk)
            }
            .frame(width: 48)
            .padding(.vertical, 14)

            Rectangle()
                .fill(Wafu16Palette.rule)
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Wafu16Palette.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundStyle(Wafu16Palette.mutedInk)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)

            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct Wafu16HighlightStep4Card: View {
    var body: some View {
        HStack(spacing: 0) {
            // 左端の朱肉縦帯
            Rectangle()
                .fill(Wafu16Palette.shu)
                .frame(width: 5)

            HStack(alignment: .center, spacing: 14) {
                // 朱肉の角印「肆・要」
                ZStack {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Wafu16Palette.shu)

                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .strokeBorder(Wafu16Palette.paper.opacity(0.9), lineWidth: 1.2)
                        .padding(3)

                    VStack(spacing: 0) {
                        Text("肆")
                            .font(.custom("HiraMinProN-W6", size: 18))
                            .foregroundStyle(Wafu16Palette.paper)
                        Text("要")
                            .font(.custom("HiraMinProN-W3", size: 10))
                            .foregroundStyle(Wafu16Palette.paper.opacity(0.92))
                    }

                    Wafu16HankoTextureOverlay(paperColor: Wafu16Palette.shuTint)
                }
                .frame(width: 46, height: 46)
                .rotationEffect(.degrees(-4))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("04")
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(Wafu16Palette.shu)
                        Text("仕上げの操作")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundStyle(Wafu16Palette.shu)
                            .tracking(1.2)
                    }

                    Text("アドレスバーの「ぁあ」から「よみび」を選ぶ")
                        .font(.custom("HiraMinProN-W6", size: 15.5))
                        .foregroundStyle(Wafu16Palette.ink)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 7) {
                        Text("ぁあ")
                            .font(.custom("HiraMinProN-W6", size: 11.5))
                            .foregroundStyle(Wafu16Palette.shu)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .strokeBorder(Wafu16Palette.shu, lineWidth: 1)
                            )

                        Text("ここで初めて本文が整う")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Wafu16Palette.shu)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 16)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Wafu16Palette.shuTint)
        .overlay(
            Rectangle()
                .strokeBorder(Wafu16Palette.ink, lineWidth: 1.6)
        )
    }
}

// MARK: - 4. Notice Box

private struct Wafu16NoticeBox: View {
    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Wafu16SmallSquareHanko(text: "注", size: 28, angle: -3)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("サイトごとに許可が要る")
                    .font(.custom("HiraMinProN-W6", size: 14.5))
                    .foregroundStyle(Wafu16Palette.ink)
                    .tracking(0.6)

                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12.5, weight: .regular))
                    .foregroundStyle(Wafu16Palette.mutedInk)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Wafu16Palette.paperSub)
        .overlay(
            Rectangle()
                .strokeBorder(Wafu16Palette.rule, lineWidth: 1)
        )
        .overlay(Wafu16CornerTicks())
    }
}

/// 四隅のL字トンボ（隅飾り）
private struct Wafu16CornerTicks: View {
    var body: some View {
        Canvas { context, size in
            let len: CGFloat = 8
            let w = size.width
            let h = size.height
            var path = Path()

            // 左上
            path.move(to: CGPoint(x: 0, y: len))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: len, y: 0))
            // 右上
            path.move(to: CGPoint(x: w - len, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: len))
            // 左下
            path.move(to: CGPoint(x: 0, y: h - len))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: len, y: h))
            // 右下
            path.move(to: CGPoint(x: w - len, y: h))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w, y: h - len))

            context.stroke(path, with: .color(Wafu16Palette.ink), lineWidth: 1.4)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 5. Primary Button

private struct Wafu16PrimaryButton: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Wafu16Palette.paper)

                Text("Safari を開く")
                    .font(.custom("HiraMinProN-W6", size: 16.5))
                    .foregroundStyle(Wafu16Palette.paper)
                    .tracking(2.5)

                Spacer()

                // 朱肉の丸印アクセント
                ZStack {
                    Circle()
                        .fill(Wafu16Palette.shu)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Wafu16Palette.paper)
                }
                .frame(width: 28, height: 28)
            }
            .padding(.horizontal, 20)
            .frame(height: 54)
            .background(Wafu16Palette.ink)
            .overlay(
                Rectangle()
                    .strokeBorder(Wafu16Palette.paper.opacity(0.28), lineWidth: 0.8)
                    .padding(4)
            )
        }
    }
}

// MARK: - 6. Features Section (Small Kamon Icons)

private struct Wafu16FeaturesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Wafu16YotsumeDiamond()
                    .frame(width: 14, height: 14)
                Text("三つのしつらえ")
                    .font(.custom("HiraMinProN-W6", size: 15))
                    .foregroundStyle(Wafu16Palette.ink)
                    .tracking(2)
                Spacer()
            }

            VStack(spacing: 0) {
                Rectangle().fill(Wafu16Palette.ink).frame(height: 1.2)

                Wafu16FeatureRow(
                    kind: .minchoBook,
                    text: "本文だけを抜き出して明朝体で組む"
                )
                Rectangle().fill(Wafu16Palette.rule).frame(height: 1)

                Wafu16FeatureRow(
                    kind: .lineSpacing,
                    text: "行間と文字の大きさを端末に合わせる"
                )
                Rectangle().fill(Wafu16Palette.rule).frame(height: 1)

                Wafu16FeatureRow(
                    kind: .bookmark,
                    text: "読んだ位置を覚えておく"
                )

                Rectangle().fill(Wafu16Palette.ink).frame(height: 1.2)
            }
        }
    }
}

private enum Wafu16MiniKamonKind {
    case minchoBook
    case lineSpacing
    case bookmark
}

private struct Wafu16FeatureRow: View {
    let kind: Wafu16MiniKamonKind
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Wafu16MiniKamonIcon(kind: kind)
                .frame(width: 30, height: 30)

            Text(text)
                .font(.system(size: 13.5, weight: .medium))
                .foregroundStyle(Wafu16Palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

/// 説明 3 行用の幾何学小家紋アイコン
private struct Wafu16MiniKamonIcon: View {
    let kind: Wafu16MiniKamonKind

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let cx = size.width / 2
            let cy = size.height / 2
            let r = s * 0.44

            // 外円（家紋枠）
            context.stroke(
                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                with: .color(Wafu16Palette.ink),
                lineWidth: 1.6
            )

            switch kind {
            case .minchoBook:
                // 丸に竪書（縦組み3本線＋角枠）
                let box = CGRect(x: cx - s * 0.19, y: cy - s * 0.19, width: s * 0.38, height: s * 0.38)
                context.stroke(Path(box), with: .color(Wafu16Palette.ink), lineWidth: 1.3)
                var lines = Path()
                let offsets: [CGFloat] = [-0.08, 0.0, 0.08]
                for offset in offsets {
                    lines.move(to: CGPoint(x: cx + s * offset, y: cy - s * 0.11))
                    lines.addLine(to: CGPoint(x: cx + s * offset, y: cy + s * 0.11))
                }
                context.stroke(lines, with: .color(Wafu16Palette.ink), lineWidth: 1.2)

            case .lineSpacing:
                // 丸に調（均等な水平線）
                var lines = Path()
                let offsets: [CGFloat] = [-0.12, 0.0, 0.12]
                for offset in offsets {
                    let halfW: CGFloat = (offset == 0.0) ? 0.19 : 0.14
                    lines.move(to: CGPoint(x: cx - s * halfW, y: cy + s * offset))
                    lines.addLine(to: CGPoint(x: cx + s * halfW, y: cy + s * offset))
                }
                context.stroke(lines, with: .color(Wafu16Palette.ink), lineWidth: 1.5)

            case .bookmark:
                // 丸に栞（切り込みのあるしおり紋）
                var bm = Path()
                bm.move(to: CGPoint(x: cx - s * 0.13, y: cy - s * 0.21))
                bm.addLine(to: CGPoint(x: cx + s * 0.13, y: cy - s * 0.21))
                bm.addLine(to: CGPoint(x: cx + s * 0.13, y: cy + s * 0.22))
                bm.addLine(to: CGPoint(x: cx, y: cy + s * 0.11))
                bm.addLine(to: CGPoint(x: cx - s * 0.13, y: cy + s * 0.22))
                bm.closeSubpath()
                context.fill(bm, with: .color(Wafu16Palette.ink))
            }
        }
    }
}

// MARK: - 7. Footer (Colophon)

private struct Wafu16Footer: View {
    var body: some View {
        VStack(spacing: 14) {
            Wafu16TopDoubleRule(inverted: true)

            HStack(spacing: 10) {
                Wafu16SmallSquareHanko(text: "よ", size: 20, angle: -4)

                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(.custom("HiraMinProN-W3", size: 11.5))
                    .foregroundStyle(Wafu16Palette.mutedInk)
                    .tracking(0.6)
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    Wafu16Screen()
}
