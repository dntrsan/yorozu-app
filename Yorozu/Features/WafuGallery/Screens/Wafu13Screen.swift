import SwiftUI

// MARK: - 13_yuki: 雪と銀 — 静かな冬の朝

struct Wafu13Screen: View {
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

        var titleText: String {
            switch self {
            case .on: return "機能拡張はオンです"
            case .off: return "機能拡張はオフです"
            case .checking: return "拡張の状態を確認中…"
            }
        }

        var detailText: String {
            switch self {
            case .on: return "Safari で記事を開き、「ぁあ」から呼び出せます"
            case .off: return "下の順に設定アプリから「よみび」をオンにしてください"
            case .checking: return "Safari の設定を読み込んでいます"
            }
        }

        var dotColor: Color {
            switch self {
            case .on: return Wafu13Palette.iceBlue
            case .off: return Wafu13Palette.silverMuted
            case .checking: return Wafu13Palette.frostBlue
            }
        }
    }

    @State private var extState: ExtState = .on
    @State private var pulseGlow: Bool = false

    var body: some View {
        ZStack {
            Wafu13SnowBackdrop(pulseGlow: pulseGlow)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Wafu13HeroSection()
                        .padding(.top, 34)
                        .padding(.bottom, 28)

                    Wafu13StatusCard(state: extState, pulseGlow: pulseGlow) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            extState = extState.next
                        }
                    }
                    .padding(.bottom, 30)

                    Wafu13StepsSection()
                        .padding(.bottom, 18)

                    Wafu13NoticeCard()
                        .padding(.bottom, 26)

                    Wafu13PrimaryButton()
                        .padding(.bottom, 34)

                    Wafu13FeaturesSection()
                        .padding(.bottom, 34)

                    Wafu13Footer()
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 22)
                .frame(maxWidth: 440)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }
}

// MARK: - Palette

private enum Wafu13Palette {
    static let snowTop      = Color(wafu13Hex: 0xF7F9FC) // 朝雪
    static let snowBottom   = Color(wafu13Hex: 0xEBF0F5) // 薄氷
    static let cardSurface  = Color(wafu13Hex: 0xFFFFFF, alpha: 0.86) // 白磁
    static let iceMist      = Color(wafu13Hex: 0xE6EEF5) // 氷霞
    static let iceHighlight = Color(wafu13Hex: 0xEDF4FA) // 雪明かり
    static let silverLine   = Color(wafu13Hex: 0xCFD8E2) // 淡銀鼠
    static let silverSoft   = Color(wafu13Hex: 0xDCE3EB) // 銀霞
    static let silverMuted  = Color(wafu13Hex: 0x8A98A8) // 銀鼠
    static let slateSub     = Color(wafu13Hex: 0x566575) // 鈍銀
    static let ink          = Color(wafu13Hex: 0x1E2935) // 墨銀
    static let iceBlue      = Color(wafu13Hex: 0x356480) // 氷青
    static let frostBlue    = Color(wafu13Hex: 0x6D94AD) // 薄縹
    static let deepIndigo   = Color(wafu13Hex: 0x243F54) // 鉄藍（主ボタン上）
    static let deepSlate    = Color(wafu13Hex: 0x345770) // 藍銀（主ボタン下）
}

private extension Color {
    init(wafu13Hex hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Typography Helpers

private enum Wafu13Font {
    static func mincho(_ size: CGFloat, bold: Bool = false) -> Font {
        Font.custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size)
    }

    static func gothic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

// MARK: - Traditional Yukiwa-mon (雪輪紋) Shape

private struct Wafu13YukiwaShape: Shape {
    var notchDistanceRatio: Double = 1.04
    var notchRadiusRatio: Double = 0.23

    func path(in rect: CGRect) -> Path {
        let cx = Double(rect.midX)
        let cy = Double(rect.midY)
        let outerR = Double(min(rect.width, rect.height)) * 0.5
        let d = outerR * notchDistanceRatio
        let r = outerR * notchRadiusRatio

        let cosDelta = min(max((outerR * outerR + d * d - r * r) / (2.0 * outerR * d), -1.0), 1.0)
        let delta = acos(cosDelta)

        let cosBeta = min(max((d * d + r * r - outerR * outerR) / (2.0 * d * r), -1.0), 1.0)
        let beta = acos(cosBeta)

        let notchCount = 6
        let stepAngle = (2.0 * Double.pi) / Double(notchCount)
        let baseAngle = -Double.pi / 2.0

        var path = Path()
        let outerSegments = 14
        let innerSegments = 12
        var isFirst = true

        for i in 0..<notchCount {
            let alpha0 = baseAngle + Double(i) * stepAngle
            let alpha1 = baseAngle + Double(i + 1) * stepAngle

            // 外円弧: alpha0 + delta -> alpha1 - delta
            let outerStart = alpha0 + delta
            let outerEnd = alpha1 - delta
            for s in 0...outerSegments {
                let t = outerStart + (outerEnd - outerStart) * (Double(s) / Double(outerSegments))
                let pt = CGPoint(x: cx + outerR * cos(t), y: cy + outerR * sin(t))
                if isFirst {
                    path.move(to: pt)
                    isFirst = false
                } else {
                    path.addLine(to: pt)
                }
            }

            // くぼみ弧 (alpha1 位置): 原点側を通る内向き円弧
            let nx = cx + d * cos(alpha1)
            let ny = cy + d * sin(alpha1)
            let notchStart = alpha1 + Double.pi + beta
            let notchEnd = alpha1 + Double.pi - beta
            for s in 1...innerSegments {
                let t = notchStart + (notchEnd - notchStart) * (Double(s) / Double(innerSegments))
                let pt = CGPoint(x: nx + r * cos(t), y: ny + r * sin(t))
                path.addLine(to: pt)
            }
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Backdrop (静かな雪明かりと雪輪紋)

private struct Wafu13SnowBackdrop: View {
    let pulseGlow: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Wafu13Palette.snowTop, Wafu13Palette.snowBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 背景の大きな雪輪紋と淡い銀の紋様
            GeometryReader { geo in
                ZStack {
                    // 右上に大きく掛かる雪輪（外輪＋内輪）
                    Wafu13DoubleYukiwaWatermark(size: 290, strokeOpacity: 0.45)
                        .position(x: geo.size.width * 0.88, y: 84)

                    // 左中ほどに小さく佇む雪輪
                    Wafu13DoubleYukiwaWatermark(size: 168, strokeOpacity: 0.34)
                        .position(x: geo.size.width * 0.06, y: 390)

                    // 下部右寄りの淡い雪輪
                    Wafu13DoubleYukiwaWatermark(size: 210, strokeOpacity: 0.28)
                        .position(x: geo.size.width * 0.92, y: geo.size.height * 0.78)

                    // 朝の雪明かりの柔らかな光溜まり（控えめな呼吸アニメーション）
                    RadialGradient(
                        colors: [
                            Color.white.opacity(pulseGlow ? 0.78 : 0.48),
                            Color.white.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 210
                    )
                    .frame(width: 420, height: 420)
                    .position(x: geo.size.width * 0.5, y: 120)

                    // 静かに浮かぶ微細な銀雪の粒
                    Canvas { context, size in
                        let flakes: [(CGFloat, CGFloat, CGFloat, Double)] = [
                            (0.14, 0.08, 2.6, 0.55),
                            (0.28, 0.14, 1.8, 0.40),
                            (0.76, 0.06, 2.2, 0.48),
                            (0.84, 0.20, 3.0, 0.36),
                            (0.10, 0.25, 2.0, 0.38),
                            (0.66, 0.16, 1.6, 0.35),
                            (0.90, 0.44, 2.4, 0.32),
                            (0.12, 0.62, 2.2, 0.30)
                        ]
                        for (fx, fy, radius, opacity) in flakes {
                            let pt = CGPoint(x: size.width * fx, y: size.height * fy)
                            let circle = Path(ellipseIn: CGRect(
                                x: pt.x - radius,
                                y: pt.y - radius,
                                width: radius * 2,
                                height: radius * 2
                            ))
                            context.fill(circle, with: .color(Wafu13Palette.silverMuted.opacity(opacity)))
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct Wafu13DoubleYukiwaWatermark: View {
    let size: CGFloat
    let strokeOpacity: Double

    var body: some View {
        ZStack {
            Wafu13YukiwaShape()
                .fill(Color.white.opacity(0.32))
            Wafu13YukiwaShape()
                .stroke(Wafu13Palette.silverLine.opacity(strokeOpacity), lineWidth: 1.0)
            Wafu13YukiwaShape(notchDistanceRatio: 1.07, notchRadiusRatio: 0.20)
                .stroke(Wafu13Palette.silverLine.opacity(strokeOpacity * 0.65), lineWidth: 0.75)
                .frame(width: size * 0.80, height: size * 0.80)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 1. Hero Section

private struct Wafu13HeroSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Wafu13AppMark()
                .frame(width: 82, height: 82)
                .padding(.bottom, 18)

            Text("よみび")
                .font(Wafu13Font.mincho(30, bold: false))
                .tracking(8)
                .foregroundStyle(Wafu13Palette.ink)
                .padding(.leading, 8) // tracking の右余白を視覚補正
                .padding(.bottom, 10)

            Text("ウェブの文章を、本のように読む")
                .font(Wafu13Font.mincho(14))
                .tracking(1.2)
                .foregroundStyle(Wafu13Palette.slateSub)
                .padding(.bottom, 18)

            HStack(spacing: 8) {
                Wafu13TagPill(label: "v1.0")
                Wafu13TagPill(label: "iOS 18+")
                Wafu13TagPill(label: "Safari")
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Wafu13AppMark: View {
    var body: some View {
        ZStack {
            // 雪輪の白銀メダル
            Wafu13YukiwaShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(wafu13Hex: 0xE7EEF5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Wafu13Palette.ink.opacity(0.08), radius: 12, x: 0, y: 6)

            // 外側の細銀線
            Wafu13YukiwaShape()
                .stroke(
                    LinearGradient(
                        colors: [Color(wafu13Hex: 0xB8C5D3), Color(wafu13Hex: 0xDAE2EA)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.25
                )

            // 内側の二重雪輪
            Wafu13YukiwaShape(notchDistanceRatio: 1.07, notchRadiusRatio: 0.20)
                .stroke(Wafu13Palette.silverLine.opacity(0.85), lineWidth: 0.75)
                .padding(8)

            // 中央の開いた和本・縦書き行・氷青の栞
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let cx = w * 0.5
                let cy = h * 0.51

                let bookW: CGFloat = 28
                let bookH: CGFloat = 22
                let topY = cy - bookH * 0.5
                let botY = cy + bookH * 0.5

                // 左頁
                var leftPage = Path()
                leftPage.move(to: CGPoint(x: cx, y: topY + 2))
                leftPage.addQuadCurve(
                    to: CGPoint(x: cx - bookW * 0.5, y: topY),
                    control: CGPoint(x: cx - bookW * 0.24, y: topY - 1.5)
                )
                leftPage.addLine(to: CGPoint(x: cx - bookW * 0.5, y: botY - 1))
                leftPage.addQuadCurve(
                    to: CGPoint(x: cx, y: botY + 1.5),
                    control: CGPoint(x: cx - bookW * 0.24, y: botY - 1.5)
                )
                leftPage.closeSubpath()

                // 右頁
                var rightPage = Path()
                rightPage.move(to: CGPoint(x: cx, y: topY + 2))
                rightPage.addQuadCurve(
                    to: CGPoint(x: cx + bookW * 0.5, y: topY),
                    control: CGPoint(x: cx + bookW * 0.24, y: topY - 1.5)
                )
                rightPage.addLine(to: CGPoint(x: cx + bookW * 0.5, y: botY - 1))
                rightPage.addQuadCurve(
                    to: CGPoint(x: cx, y: botY + 1.5),
                    control: CGPoint(x: cx + bookW * 0.24, y: botY - 1.5)
                )
                rightPage.closeSubpath()

                context.fill(leftPage, with: .color(Color.white.opacity(0.95)))
                context.fill(rightPage, with: .color(Color.white.opacity(0.95)))
                context.stroke(leftPage, with: .color(Wafu13Palette.ink.opacity(0.75)), lineWidth: 1.15)
                context.stroke(rightPage, with: .color(Wafu13Palette.ink.opacity(0.75)), lineWidth: 1.15)

                // 縦書きの本文ライン（右頁2本・左頁2本）
                let lineOffsets: [(CGFloat, CGFloat)] = [
                    (cx + 4.5, 11.5),
                    (cx + 9.0, 9.0),
                    (cx - 4.5, 11.0),
                    (cx - 9.0, 8.0)
                ]
                for (lx, len) in lineOffsets {
                    var line = Path()
                    line.move(to: CGPoint(x: lx, y: topY + 4.5))
                    line.addLine(to: CGPoint(x: lx, y: topY + 4.5 + len))
                    context.stroke(line, with: .color(Wafu13Palette.silverMuted), lineWidth: 1.0)
                }

                // 氷青の細い栞（中央の綴じ目から下へわずかに垂れる）
                var ribbon = Path()
                ribbon.move(to: CGPoint(x: cx - 1.8, y: botY - 4.5))
                ribbon.addLine(to: CGPoint(x: cx + 1.8, y: botY - 4.5))
                ribbon.addLine(to: CGPoint(x: cx + 1.8, y: botY + 6.5))
                ribbon.addLine(to: CGPoint(x: cx, y: botY + 4.2))
                ribbon.addLine(to: CGPoint(x: cx - 1.8, y: botY + 6.5))
                ribbon.closeSubpath()
                context.fill(ribbon, with: .color(Wafu13Palette.iceBlue))
            }
        }
    }
}

private struct Wafu13TagPill: View {
    let label: String

    var body: some View {
        Text(label)
            .font(Wafu13Font.gothic(11, weight: .medium))
            .tracking(0.6)
            .foregroundStyle(Wafu13Palette.slateSub)
            .padding(.horizontal, 11)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.72))
            )
            .overlay(
                Capsule()
                    .stroke(Wafu13Palette.silverLine, lineWidth: 0.85)
            )
    }
}

// MARK: - 2. Status Card

private struct Wafu13StatusCard: View {
    let state: Wafu13Screen.ExtState
    let pulseGlow: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // 雪輪の小紋＋呼吸する状態の光点
                ZStack {
                    Wafu13YukiwaShape()
                        .fill(state.dotColor.opacity(0.10))
                        .frame(width: 40, height: 40)
                    Wafu13YukiwaShape()
                        .stroke(state.dotColor.opacity(0.35), lineWidth: 0.9)
                        .frame(width: 40, height: 40)

                    Circle()
                        .fill(state.dotColor.opacity(pulseGlow && state != .off ? 0.28 : 0.08))
                        .frame(width: 18, height: 18)

                    Circle()
                        .fill(state.dotColor)
                        .frame(width: 8, height: 8)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(state.titleText)
                            .font(Wafu13Font.mincho(15, bold: true))
                            .foregroundStyle(Wafu13Palette.ink)

                        Spacer(minLength: 4)

                        Text(state.badgeText)
                            .font(Wafu13Font.gothic(11, weight: .semibold))
                            .foregroundStyle(state == .on ? Wafu13Palette.iceBlue : Wafu13Palette.slateSub)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2.5)
                            .background(
                                Capsule()
                                    .fill(state.dotColor.opacity(0.12))
                            )
                    }

                    Text(state.detailText)
                        .font(Wafu13Font.gothic(12))
                        .foregroundStyle(Wafu13Palette.slateSub)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Wafu13Palette.cardSurface)
                    .shadow(color: Wafu13Palette.ink.opacity(0.045), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        state == .on ? Wafu13Palette.iceBlue.opacity(0.30) : Wafu13Palette.silverLine,
                        lineWidth: 1.0
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("タップすると拡張の状態表示を切り替えます")
    }
}

// MARK: - 3. Steps Section (4手順・手順4を強調)

private struct Wafu13StepItem: Identifiable {
    let id: Int
    let kanjiNum: String
    let title: String
    let note: String?
    let isEmphasized: Bool
}

private struct Wafu13StepsSection: View {
    private let steps: [Wafu13StepItem] = [
        Wafu13StepItem(
            id: 1,
            kanjiNum: "一",
            title: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く",
            note: "設定アプリのいちばん下のほう",
            isEmphasized: false
        ),
        Wafu13StepItem(
            id: 2,
            kanjiNum: "二",
            title: "「よみび」をオンにする",
            note: nil,
            isEmphasized: false
        ),
        Wafu13StepItem(
            id: 3,
            kanjiNum: "三",
            title: "Safari で好きな記事を開く",
            note: nil,
            isEmphasized: false
        ),
        Wafu13StepItem(
            id: 4,
            kanjiNum: "四",
            title: "アドレスバーの「ぁあ」から「よみび」を選ぶ",
            note: "ここで初めて本文が整う",
            isEmphasized: true
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Wafu13SectionHeader(title: "設定のてじゅん")

            VStack(spacing: 10) {
                ForEach(steps) { step in
                    Wafu13StepRow(step: step, isLast: step.id == steps.count)
                }
            }
        }
    }
}

private struct Wafu13SectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Wafu13YukiwaShape()
                .stroke(Wafu13Palette.silverMuted, lineWidth: 1.1)
                .frame(width: 13, height: 13)

            Text(title)
                .font(Wafu13Font.mincho(13, bold: true))
                .tracking(2.0)
                .foregroundStyle(Wafu13Palette.slateSub)

            Rectangle()
                .fill(Wafu13Palette.silverLine.opacity(0.85))
                .frame(height: 0.75)
        }
    }
}

private struct Wafu13StepRow: View {
    let step: Wafu13StepItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            // 左側の番号紋と銀の導線
            VStack(spacing: 0) {
                ZStack {
                    if step.isEmphasized {
                        Wafu13YukiwaShape()
                            .fill(Wafu13Palette.iceBlue)
                            .frame(width: 30, height: 30)
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 28, height: 28)
                        Circle()
                            .stroke(Wafu13Palette.silverLine, lineWidth: 1.0)
                            .frame(width: 28, height: 28)
                    }

                    Text(step.kanjiNum)
                        .font(Wafu13Font.mincho(13, bold: step.isEmphasized))
                        .foregroundStyle(step.isEmphasized ? Color.white : Wafu13Palette.ink)
                }
                .padding(.top, 1)

                if !isLast {
                    Rectangle()
                        .fill(Wafu13Palette.silverLine.opacity(0.8))
                        .frame(width: 1)
                        .frame(minHeight: 16, maxHeight: .infinity)
                        .padding(.top, 5)
                }
            }
            .frame(width: 30)

            // 本文側
            VStack(alignment: .leading, spacing: 5) {
                if step.isEmphasized {
                    Text("仕上げのひと手間")
                        .font(Wafu13Font.gothic(10.5, weight: .semibold))
                        .tracking(1.0)
                        .foregroundStyle(Wafu13Palette.iceBlue)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Wafu13Palette.iceBlue.opacity(0.11))
                        )
                }

                Text(step.title)
                    .font(Wafu13Font.mincho(step.isEmphasized ? 15 : 14, bold: step.isEmphasized))
                    .foregroundStyle(Wafu13Palette.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if let note = step.note {
                    Text(note)
                        .font(Wafu13Font.gothic(12, weight: step.isEmphasized ? .medium : .regular))
                        .foregroundStyle(step.isEmphasized ? Wafu13Palette.iceBlue : Wafu13Palette.slateSub)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, step.isEmphasized ? 14 : 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(step.isEmphasized ? Wafu13Palette.iceHighlight : Wafu13Palette.cardSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        step.isEmphasized ? Wafu13Palette.iceBlue.opacity(0.45) : Wafu13Palette.silverSoft,
                        lineWidth: step.isEmphasized ? 1.2 : 0.9
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(Wafu13Palette.iceBlue.opacity(step.isEmphasized ? 0.16 : 0), lineWidth: 0.75)
                    .padding(3)
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 4. Notice Card

private struct Wafu13NoticeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Wafu13Palette.iceBlue)

                Text("サイトごとに許可が要る")
                    .font(Wafu13Font.mincho(13.5, bold: true))
                    .foregroundStyle(Wafu13Palette.ink)
            }

            Text("初めて開くサイトでは、拡張を一度許可してください")
                .font(Wafu13Font.gothic(12.5))
                .foregroundStyle(Wafu13Palette.slateSub)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 26)
        .padding(.trailing, 15)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Wafu13Palette.iceMist.opacity(0.75))
        )
        .overlay(alignment: .leading) {
            Capsule()
                .fill(Wafu13Palette.frostBlue)
                .frame(width: 2.5)
                .padding(.vertical, 12)
                .padding(.leading, 13)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Wafu13Palette.silverLine.opacity(0.9), lineWidth: 0.85)
        )
    }
}

// MARK: - 5. Primary Button

private struct Wafu13PrimaryButton: View {
    private let safariURL = URL(string: "https://www.apple.com/jp/safari/")!

    var body: some View {
        Link(destination: safariURL) {
            HStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 16, weight: .regular))
                Text("Safari を開く")
                    .font(Wafu13Font.mincho(16, bold: true))
                    .tracking(2.0)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .medium))
                    .opacity(0.82)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 22)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Wafu13Palette.deepIndigo, Wafu13Palette.deepSlate],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Wafu13Palette.deepIndigo.opacity(0.24), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 0.8)
                    .padding(3.5)
            )
        }
    }
}

// MARK: - 6. Features (説明 3 行)

private struct Wafu13FeaturesSection: View {
    private let items: [(icon: String, text: String)] = [
        ("doc.plaintext", "本文だけを抜き出して明朝体で組む"),
        ("textformat.size", "行間と文字の大きさを端末に合わせる"),
        ("bookmark", "読んだ位置を覚えておく")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Wafu13SectionHeader(title: "よみびの仕立て")

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 13) {
                        ZStack {
                            Circle()
                                .fill(Wafu13Palette.iceMist)
                                .frame(width: 32, height: 32)
                            Circle()
                                .stroke(Wafu13Palette.silverLine, lineWidth: 0.75)
                                .frame(width: 32, height: 32)
                            Image(systemName: item.icon)
                                .font(.system(size: 13.5, weight: .regular))
                                .foregroundStyle(Wafu13Palette.iceBlue)
                        }

                        Text(item.text)
                            .font(Wafu13Font.mincho(13.5))
                            .foregroundStyle(Wafu13Palette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Wafu13Palette.silverSoft)
                            .frame(height: 0.75)
                            .padding(.leading, 60)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Wafu13Palette.cardSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Wafu13Palette.silverSoft, lineWidth: 0.9)
            )
        }
    }
}

// MARK: - 7. Footer

private struct Wafu13Footer: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Wafu13Palette.silverLine)
                    .frame(width: 32, height: 0.75)
                Wafu13YukiwaShape()
                    .stroke(Wafu13Palette.silverMuted, lineWidth: 0.9)
                    .frame(width: 11, height: 11)
                Rectangle()
                    .fill(Wafu13Palette.silverLine)
                    .frame(width: 32, height: 0.75)
            }

            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(Wafu13Font.mincho(11.5))
                .tracking(0.8)
                .foregroundStyle(Wafu13Palette.silverMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    Wafu13Screen()
}
