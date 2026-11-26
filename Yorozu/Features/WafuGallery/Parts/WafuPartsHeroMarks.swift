import SwiftUI

// MARK: - Private Color Helper & Palette

private extension Color {
    init(wphmHex: UInt32, alpha: Double = 1.0) {
        let r = Double((wphmHex >> 16) & 0xFF) / 255.0
        let g = Double((wphmHex >> 8) & 0xFF) / 255.0
        let b = Double(wphmHex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum WPHeroMarkPalette {
    static let washiLight = Color(wphmHex: 0xF6F3EB)
    static let cardLight = Color(wphmHex: 0xFCFBF7)
    static let inkLight = Color(wphmHex: 0x1E1C19)
    static let subLight = Color(wphmHex: 0x676158)
    static let lineLight = Color(wphmHex: 0xDDD7C9)

    static let sumiDark = Color(wphmHex: 0x141311)
    static let cardDark = Color(wphmHex: 0x1E1C19)
    static let inkDark = Color(wphmHex: 0xEFECE4)
    static let subDark = Color(wphmHex: 0x9C9589)
    static let lineDark = Color(wphmHex: 0x33302A)

    static let tetsukon = Color(wphmHex: 0x1E2D3D)
    static let shuin = Color(wphmHex: 0xB8372B)
    static let shuinBright = Color(wphmHex: 0xDC6255)
    static let kin = Color(wphmHex: 0xC5A052)
    static let asagi = Color(wphmHex: 0x46768A)
    static let ai = Color(wphmHex: 0x223B55)
    static let matsuba = Color(wphmHex: 0x3E5E49)
    static let wakatake = Color(wphmHex: 0x7BA689)
    static let nightSky = Color(wphmHex: 0x182334)
    static let moonGold = Color(wphmHex: 0xE6CA7E)
    static let sumi = Color(wphmHex: 0x22201D)
}

// MARK: - 1. 家紋・丸に開き本（まるにひらきほん）

/// 伝統家紋「丸に〜」の様式で、見開きの和本を端正に描いた紋章マーク。
struct WPHeroMarkKamonBook: View {
    var size: CGFloat
    var primaryColor: Color
    var accentColor: Color

    init(
        size: CGFloat = 72,
        primaryColor: Color = Color(.sRGB, red: 0.118, green: 0.176, blue: 0.239),
        accentColor: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169)
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.accentColor = accentColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let cx = sz.width * 0.5
            let cy = sz.height * 0.5

            // 外輪（家紋の丸輪）
            let outerR = s * 0.44
            let ringWidth = s * 0.068
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2, height: outerR * 2)),
                with: .color(primaryColor),
                lineWidth: ringWidth
            )

            // 内側の極細輪
            let innerR = s * 0.355
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - innerR, y: cy - innerR, width: innerR * 2, height: innerR * 2)),
                with: .color(primaryColor.opacity(0.35)),
                lineWidth: max(0.8, s * 0.012)
            )

            // 見開き本の左頁
            var leftPage = Path()
            leftPage.move(to: CGPoint(x: cx - s * 0.025, y: cy - s * 0.17))
            leftPage.addQuadCurve(
                to: CGPoint(x: cx - s * 0.25, y: cy - s * 0.14),
                control: CGPoint(x: cx - s * 0.14, y: cy - s * 0.22)
            )
            leftPage.addLine(to: CGPoint(x: cx - s * 0.25, y: cy + s * 0.16))
            leftPage.addQuadCurve(
                to: CGPoint(x: cx - s * 0.025, y: cy + s * 0.19),
                control: CGPoint(x: cx - s * 0.14, y: cy + s * 0.12)
            )
            leftPage.closeSubpath()
            ctx.fill(leftPage, with: .color(primaryColor))

            // 見開き本の右頁
            var rightPage = Path()
            rightPage.move(to: CGPoint(x: cx + s * 0.025, y: cy - s * 0.17))
            rightPage.addQuadCurve(
                to: CGPoint(x: cx + s * 0.25, y: cy - s * 0.14),
                control: CGPoint(x: cx + s * 0.14, y: cy - s * 0.22)
            )
            rightPage.addLine(to: CGPoint(x: cx + s * 0.25, y: cy + s * 0.16))
            rightPage.addQuadCurve(
                to: CGPoint(x: cx + s * 0.025, y: cy + s * 0.19),
                control: CGPoint(x: cx + s * 0.14, y: cy + s * 0.12)
            )
            rightPage.closeSubpath()
            ctx.fill(rightPage, with: .color(primaryColor))

            // 中央の栞（朱の菱星）
            let d = s * 0.048
            var diamond = Path()
            diamond.move(to: CGPoint(x: cx, y: cy - s * 0.25 - d))
            diamond.addLine(to: CGPoint(x: cx + d * 0.72, y: cy - s * 0.25))
            diamond.addLine(to: CGPoint(x: cx, y: cy - s * 0.25 + d))
            diamond.addLine(to: CGPoint(x: cx - d * 0.72, y: cy - s * 0.25))
            diamond.closeSubpath()
            ctx.fill(diamond, with: .color(accentColor))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 2. 落款・朱文角印（しゅぶんかくいん）

/// 文豪の蔵書印のように「よみび」を縦二列に配した朱印マーク。
struct WPHeroMarkRakkanSeal: View {
    var size: CGFloat
    var sealColor: Color
    var inkColor: Color

    init(
        size: CGFloat = 72,
        sealColor: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169),
        inkColor: Color = Color(.sRGB, red: 0.980, green: 0.969, blue: 0.941)
    ) {
        self.size = size
        self.sealColor = sealColor
        self.inkColor = inkColor
    }

    var body: some View {
        let radius = size * 0.13
        let fontSize = size * 0.27

        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(sealColor)

            // 二重の内彫り枠
            RoundedRectangle(cornerRadius: radius * 0.65)
                .stroke(inkColor.opacity(0.75), lineWidth: max(1.0, size * 0.022))
                .padding(size * 0.085)

            // 右から縦読み: 右列「よ・み」、左列「び・●」
            HStack(spacing: size * 0.05) {
                VStack(spacing: size * 0.02) {
                    Text("び")
                        .font(.custom("HiraMinProN-W6", size: fontSize))
                        .foregroundStyle(inkColor)
                    Circle()
                        .stroke(inkColor.opacity(0.9), lineWidth: max(1.2, size * 0.025))
                        .frame(width: size * 0.15, height: size * 0.15)
                        .padding(.top, size * 0.05)
                }
                VStack(spacing: -size * 0.02) {
                    Text("よ")
                        .font(.custom("HiraMinProN-W6", size: fontSize))
                        .foregroundStyle(inkColor)
                    Text("み")
                        .font(.custom("HiraMinProN-W6", size: fontSize))
                        .foregroundStyle(inkColor)
                }
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(-2.5))
    }
}

// MARK: - 3. 円相・一筆書（えんそう）

/// 強弱のある一筆の円相の中に、縦組みの三行と朱の句点を宿した禅マーク。
struct WPHeroMarkEnsoCircle: View {
    var size: CGFloat
    var brushColor: Color
    var accentColor: Color

    init(
        size: CGFloat = 72,
        brushColor: Color = Color(.sRGB, red: 0.133, green: 0.125, blue: 0.114),
        accentColor: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169)
    ) {
        self.size = size
        self.brushColor = brushColor
        self.accentColor = accentColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let cx = sz.width * 0.5
            let cy = sz.height * 0.5
            let baseR = s * 0.39

            // 筆圧の強弱を多段の短い弧で再現（右上をわずかに開ける）
            let steps = 54
            let startDeg: CGFloat = -28.0
            let sweepDeg: CGFloat = 324.0

            for i in 0..<steps {
                let t0 = CGFloat(i) / CGFloat(steps)
                let t1 = CGFloat(i + 1) / CGFloat(steps)
                let a0 = (startDeg + sweepDeg * t0) * .pi / 180.0
                let a1 = (startDeg + sweepDeg * t1) * .pi / 180.0

                // 入りが太く、後半にかけて自然に細く抜ける
                let taper = sin(t0 * .pi) * 0.65 + (1.0 - t0) * 0.55
                let width = max(1.0, s * 0.088 * taper)
                let jitterR = baseR + sin(t0 * .pi * 2.0) * (s * 0.012)

                var seg = Path()
                seg.move(to: CGPoint(x: cx + cos(a0) * jitterR, y: cy + sin(a0) * jitterR))
                seg.addLine(to: CGPoint(x: cx + cos(a1) * jitterR, y: cy + sin(a1) * jitterR))

                let alpha = Double(min(1.0, 0.38 + (1.0 - t0) * 0.72))
                ctx.stroke(
                    seg,
                    with: .color(brushColor.opacity(alpha)),
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
            }

            // 中央の縦組み三行
            let lineW = max(1.1, s * 0.022)
            let topY = cy - s * 0.15
            let xs: [CGFloat] = [cx + s * 0.09, cx, cx - s * 0.09]
            let lens: [CGFloat] = [s * 0.30, s * 0.27, s * 0.20]

            var textLines = Path()
            for idx in 0..<3 {
                textLines.move(to: CGPoint(x: xs[idx], y: topY))
                textLines.addLine(to: CGPoint(x: xs[idx], y: topY + lens[idx]))
            }
            ctx.stroke(
                textLines,
                with: .color(brushColor.opacity(0.82)),
                style: StrokeStyle(lineWidth: lineW, lineCap: .round)
            )

            // 末尾の小さな朱の句点
            let dotR = s * 0.028
            let dotCenter = CGPoint(x: xs[2], y: topY + lens[2] + s * 0.065)
            ctx.fill(
                Path(ellipseIn: CGRect(x: dotCenter.x - dotR, y: dotCenter.y - dotR, width: dotR * 2, height: dotR * 2)),
                with: .color(accentColor)
            )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 4. 組子・麻の葉窓（くみこまど）

/// 丸窓に麻の葉組子を張り、中央に小さな光窓を抜いた数寄屋工芸マーク。
struct WPHeroMarkKumikoWindow: View {
    var size: CGFloat
    var woodColor: Color
    var accentColor: Color

    init(
        size: CGFloat = 72,
        woodColor: Color = Color(.sRGB, red: 0.243, green: 0.369, blue: 0.286),
        accentColor: Color = Color(.sRGB, red: 0.773, green: 0.627, blue: 0.322)
    ) {
        self.size = size
        self.woodColor = woodColor
        self.accentColor = accentColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let cx = sz.width * 0.5
            let cy = sz.height * 0.5
            let r = s * 0.43

            // 丸窓の背景薄塗り
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                with: .color(woodColor.opacity(0.10))
            )

            // 正六角形＋麻の葉の組子骨格
            let hexR = r * 0.88
            let angles: [CGFloat] = (0..<6).map { CGFloat($0) * (.pi / 3.0) - (.pi / 2.0) }
            let verts = angles.map { CGPoint(x: cx + cos($0) * hexR, y: cy + sin($0) * hexR) }
            let center = CGPoint(x: cx, y: cy)

            var lattice = Path()
            for i in 0..<6 {
                let v1 = verts[i]
                let v2 = verts[(i + 1) % 6]
                lattice.move(to: v1)
                lattice.addLine(to: v2)
                lattice.move(to: center)
                lattice.addLine(to: v1)

                let gx = (cx + v1.x + v2.x) / 3.0
                let gy = (cy + v1.y + v2.y) / 3.0
                let g = CGPoint(x: gx, y: gy)
                lattice.move(to: g); lattice.addLine(to: center)
                lattice.move(to: g); lattice.addLine(to: v1)
                lattice.move(to: g); lattice.addLine(to: v2)
            }

            ctx.stroke(
                lattice,
                with: .color(woodColor),
                style: StrokeStyle(lineWidth: max(1.0, s * 0.02), lineCap: .round, lineJoin: .round)
            )

            // 中央の金菱（灯りの芯）
            let coreR = s * 0.10
            var core = Path()
            core.move(to: CGPoint(x: cx, y: cy - coreR))
            core.addLine(to: CGPoint(x: cx + coreR * 0.72, y: cy))
            core.addLine(to: CGPoint(x: cx, y: cy + coreR))
            core.addLine(to: CGPoint(x: cx - coreR * 0.72, y: cy))
            core.closeSubpath()
            ctx.fill(core, with: .color(accentColor))

            // 外側の丸窓枠
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                with: .color(woodColor),
                lineWidth: max(1.8, s * 0.042)
            )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 5. 折り紙・栞菱（しおりびし）

/// 和紙の折り目を濃淡三面で表現した、モダン和風の栞（しおり）菱エンブレム。
struct WPHeroMarkOrigamiShiori: View {
    var size: CGFloat
    var primaryColor: Color
    var secondaryColor: Color
    var accentColor: Color

    init(
        size: CGFloat = 72,
        primaryColor: Color = Color(.sRGB, red: 0.133, green: 0.231, blue: 0.333),
        secondaryColor: Color = Color(.sRGB, red: 0.275, green: 0.463, blue: 0.541),
        accentColor: Color = Color(.sRGB, red: 0.773, green: 0.627, blue: 0.322)
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let cx = sz.width * 0.5
            let cy = sz.height * 0.5

            let top = CGPoint(x: cx, y: cy - s * 0.42)
            let right = CGPoint(x: cx + s * 0.34, y: cy)
            let bottom = CGPoint(x: cx, y: cy + s * 0.42)
            let left = CGPoint(x: cx - s * 0.34, y: cy)
            let mid = CGPoint(x: cx, y: cy + s * 0.05)

            // 左の折り面（濃い藍）
            var leftFacet = Path()
            leftFacet.move(to: top)
            leftFacet.addLine(to: mid)
            leftFacet.addLine(to: bottom)
            leftFacet.addLine(to: left)
            leftFacet.closeSubpath()
            ctx.fill(leftFacet, with: .color(primaryColor))

            // 右上の折り面（浅葱）
            var rightTopFacet = Path()
            rightTopFacet.move(to: top)
            rightTopFacet.addLine(to: right)
            rightTopFacet.addLine(to: mid)
            rightTopFacet.closeSubpath()
            ctx.fill(rightTopFacet, with: .color(secondaryColor))

            // 右下の折り返し面（金茶）
            var rightBottomFacet = Path()
            rightBottomFacet.move(to: mid)
            rightBottomFacet.addLine(to: right)
            rightBottomFacet.addLine(to: bottom)
            rightBottomFacet.closeSubpath()
            ctx.fill(rightBottomFacet, with: .color(accentColor))

            // 中央の細白折り筋
            var crease = Path()
            crease.move(to: top)
            crease.addLine(to: bottom)
            crease.move(to: mid)
            crease.addLine(to: right)
            ctx.stroke(crease, with: .color(Color.white.opacity(0.42)), lineWidth: max(0.8, s * 0.015))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 6. 満月と頁（つきとぺーじ）

/// 藍鉄の夜空に昇る金の満月と、手前に開く和本の稜線を重ねたアプリアイコン案。
struct WPHeroMarkMoonPages: View {
    var size: CGFloat
    var skyColor: Color
    var moonColor: Color

    init(
        size: CGFloat = 72,
        skyColor: Color = Color(.sRGB, red: 0.094, green: 0.137, blue: 0.204),
        moonColor: Color = Color(.sRGB, red: 0.902, green: 0.792, blue: 0.494)
    ) {
        self.size = size
        self.skyColor = skyColor
        self.moonColor = moonColor
    }

    var body: some View {
        let corner = size * 0.22

        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(skyColor)

            Canvas { ctx, sz in
                let s = min(sz.width, sz.height)
                let cx = sz.width * 0.5

                // 金の満月
                let moonR = s * 0.18
                let moonY = sz.height * 0.34
                ctx.fill(
                    Path(ellipseIn: CGRect(x: cx - moonR, y: moonY - moonR, width: moonR * 2, height: moonR * 2)),
                    with: .color(moonColor)
                )

                // 手前の見開き本の稜線（和紙白）
                let pageColor = Color(wphmHex: 0xF3EEE2)
                var pages = Path()
                pages.move(to: CGPoint(x: cx, y: s * 0.58))
                pages.addQuadCurve(
                    to: CGPoint(x: s * 0.15, y: s * 0.52),
                    control: CGPoint(x: s * 0.30, y: s * 0.48)
                )
                pages.addLine(to: CGPoint(x: s * 0.15, y: s * 0.78))
                pages.addQuadCurve(
                    to: CGPoint(x: cx, y: s * 0.84),
                    control: CGPoint(x: s * 0.30, y: s * 0.74)
                )
                pages.addQuadCurve(
                    to: CGPoint(x: s * 0.85, y: s * 0.78),
                    control: CGPoint(x: s * 0.70, y: s * 0.74)
                )
                pages.addLine(to: CGPoint(x: s * 0.85, y: s * 0.52))
                pages.addQuadCurve(
                    to: CGPoint(x: cx, y: s * 0.58),
                    control: CGPoint(x: s * 0.70, y: s * 0.48)
                )
                pages.closeSubpath()
                ctx.fill(pages, with: .color(pageColor))

                // のど（背の中央線）
                var spine = Path()
                spine.move(to: CGPoint(x: cx, y: s * 0.58))
                spine.addLine(to: CGPoint(x: cx, y: s * 0.84))
                ctx.stroke(spine, with: .color(skyColor.opacity(0.45)), lineWidth: max(1.0, s * 0.018))
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: corner)
                .stroke(moonColor.opacity(0.32), lineWidth: 1)
        )
    }
}

// MARK: - 7. 水引・梅結び紋（うめむすび）

/// 5回対称の円弧ループで端正に結んだ紅白水引の梅結びマーク。
struct WPHeroMarkMizuhikiUme: View {
    var size: CGFloat
    var primaryColor: Color
    var secondaryColor: Color

    init(
        size: CGFloat = 72,
        primaryColor: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169),
        secondaryColor: Color = Color(.sRGB, red: 0.773, green: 0.627, blue: 0.322)
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let cx = sz.width * 0.5
            let cy = sz.height * 0.5
            let orbitR = s * 0.205
            let petalR = s * 0.175
            let outerStroke = max(1.8, s * 0.044)
            let innerStroke = max(1.2, s * 0.025)

            var outerLoops = Path()
            var innerLoops = Path()

            for i in 0..<5 {
                let angle = CGFloat(i) * (2.0 * .pi / 5.0) - (.pi / 2.0)
                let px = cx + cos(angle) * orbitR
                let py = cy + sin(angle) * orbitR

                outerLoops.addEllipse(in: CGRect(
                    x: px - petalR,
                    y: py - petalR,
                    width: petalR * 2,
                    height: petalR * 2
                ))

                let ir = petalR * 0.68
                innerLoops.addEllipse(in: CGRect(
                    x: px - ir,
                    y: py - ir,
                    width: ir * 2,
                    height: ir * 2
                ))
            }

            ctx.stroke(outerLoops, with: .color(primaryColor), lineWidth: outerStroke)
            ctx.stroke(innerLoops, with: .color(secondaryColor), lineWidth: innerStroke)

            // 中心の結び芯
            let coreR = s * 0.095
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - coreR, y: cy - coreR, width: coreR * 2, height: coreR * 2)),
                with: .color(primaryColor)
            )
            let dotR = s * 0.04
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)),
                with: .color(secondaryColor)
            )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 8. 活版・魚尾版面（かっぱんぎょび）

/// 和装本の版心（魚尾）と縦罫線をミニマルに抽象化した活版書房マーク。
struct WPHeroMarkKappanGrid: View {
    var size: CGFloat
    var inkColor: Color
    var accentColor: Color

    init(
        size: CGFloat = 72,
        inkColor: Color = Color(.sRGB, red: 0.133, green: 0.125, blue: 0.114),
        accentColor: Color = Color(.sRGB, red: 0.722, green: 0.216, blue: 0.169)
    ) {
        self.size = size
        self.inkColor = inkColor
        self.accentColor = accentColor
    }

    var body: some View {
        Canvas { ctx, sz in
            let s = min(sz.width, sz.height)
            let pad = s * 0.11
            let frameRect = CGRect(x: pad, y: pad, width: s - pad * 2, height: s - pad * 2)
            let innerRect = frameRect.insetBy(dx: s * 0.045, dy: s * 0.045)

            // 子持ち枠（外太・内細）
            ctx.stroke(Path(frameRect), with: .color(inkColor), lineWidth: max(1.6, s * 0.032))
            ctx.stroke(Path(innerRect), with: .color(inkColor.opacity(0.65)), lineWidth: max(0.8, s * 0.013))

            // 版心（中央の柱）
            let cx = s * 0.5
            let colW = s * 0.095
            var hashira = Path()
            hashira.move(to: CGPoint(x: cx - colW * 0.5, y: innerRect.minY))
            hashira.addLine(to: CGPoint(x: cx - colW * 0.5, y: innerRect.maxY))
            hashira.move(to: CGPoint(x: cx + colW * 0.5, y: innerRect.minY))
            hashira.addLine(to: CGPoint(x: cx + colW * 0.5, y: innerRect.maxY))
            ctx.stroke(hashira, with: .color(inkColor.opacity(0.55)), lineWidth: max(0.8, s * 0.013))

            // 魚尾（ぎょび：版心の象徴記号）
            let gyobiTop = innerRect.minY + innerRect.height * 0.24
            let gyobiH = s * 0.075
            var gyobi = Path()
            gyobi.move(to: CGPoint(x: cx - colW * 0.5, y: gyobiTop))
            gyobi.addLine(to: CGPoint(x: cx + colW * 0.5, y: gyobiTop))
            gyobi.addLine(to: CGPoint(x: cx + colW * 0.5, y: gyobiTop + gyobiH))
            gyobi.addLine(to: CGPoint(x: cx, y: gyobiTop + gyobiH * 0.45))
            gyobi.addLine(to: CGPoint(x: cx - colW * 0.5, y: gyobiTop + gyobiH))
            gyobi.closeSubpath()
            ctx.fill(gyobi, with: .color(inkColor))

            // 左右の縦組み行線
            var lines = Path()
            let leftXs: [CGFloat] = [innerRect.minX + innerRect.width * 0.16, innerRect.minX + innerRect.width * 0.30]
            let rightXs: [CGFloat] = [innerRect.maxX - innerRect.width * 0.16, innerRect.maxX - innerRect.width * 0.30]
            let yStart = innerRect.minY + innerRect.height * 0.14
            let yEnd = innerRect.maxY - innerRect.height * 0.14

            for x in leftXs + rightXs {
                lines.move(to: CGPoint(x: x, y: yStart))
                lines.addLine(to: CGPoint(x: x, y: yEnd))
            }
            ctx.stroke(
                lines,
                with: .color(inkColor.opacity(0.35)),
                style: StrokeStyle(lineWidth: max(1.0, s * 0.018), lineCap: .round)
            )

            // 右上行頭の朱点（読点・強調）
            let dotR = s * 0.036
            let dotPos = CGPoint(x: rightXs[0], y: yStart + s * 0.02)
            ctx.fill(
                Path(ellipseIn: CGRect(x: dotPos.x - dotR, y: dotPos.y - dotR, width: dotR * 2, height: dotR * 2)),
                with: .color(accentColor)
            )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 見本帳 Gallery View

struct WafuPartsHeroMarksGallery: View {
    @State private var markSize: CGFloat = 68
    @State private var isDarkChrome: Bool = false

    init() {}

    var body: some View {
        let bg = isDarkChrome ? WPHeroMarkPalette.sumiDark : WPHeroMarkPalette.washiLight
        let card = isDarkChrome ? WPHeroMarkPalette.cardDark : WPHeroMarkPalette.cardLight
        let fg = isDarkChrome ? WPHeroMarkPalette.inkDark : WPHeroMarkPalette.inkLight
        let sub = isDarkChrome ? WPHeroMarkPalette.subDark : WPHeroMarkPalette.subLight
        let line = isDarkChrome ? WPHeroMarkPalette.lineDark : WPHeroMarkPalette.lineLight

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(fg: fg, sub: sub, line: line)
                controlBar(card: card, fg: fg, sub: sub, line: line)

                markCard(
                    name: "一、家紋・丸に開き本",
                    reading: "まるにひらきほん",
                    desc: "丸輪の中に和本を収めた格式ある紋章アイコン",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkKamonBook(
                        size: markSize,
                        primaryColor: isDark ? WPHeroMarkPalette.inkDark : WPHeroMarkPalette.tetsukon,
                        accentColor: isDark ? WPHeroMarkPalette.shuinBright : WPHeroMarkPalette.shuin
                    )
                }

                markCard(
                    name: "二、落款・朱文角印",
                    reading: "しゅぶんかくいん",
                    desc: "「よみび」を縦二列に組んだ蔵書印・奥付風マーク",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkRakkanSeal(
                        size: markSize,
                        sealColor: isDark ? WPHeroMarkPalette.shuinBright : WPHeroMarkPalette.shuin,
                        inkColor: isDark ? WPHeroMarkPalette.sumiDark : Color(wphmHex: 0xFAF7F0)
                    )
                }

                markCard(
                    name: "三、円相・一筆書",
                    reading: "えんそう",
                    desc: "筆致の強弱ある円環に縦三行と朱の句点を添えた禅マーク",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkEnsoCircle(
                        size: markSize,
                        brushColor: isDark ? WPHeroMarkPalette.inkDark : WPHeroMarkPalette.sumi,
                        accentColor: isDark ? WPHeroMarkPalette.shuinBright : WPHeroMarkPalette.shuin
                    )
                }

                markCard(
                    name: "四、組子・麻の葉窓",
                    reading: "くみこまど",
                    desc: "丸窓に麻の葉の組子細工と金菱を配した数寄屋風マーク",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkKumikoWindow(
                        size: markSize,
                        woodColor: isDark ? WPHeroMarkPalette.wakatake : WPHeroMarkPalette.matsuba,
                        accentColor: WPHeroMarkPalette.kin
                    )
                }

                markCard(
                    name: "五、折り紙・栞菱",
                    reading: "しおりびし",
                    desc: "藍・浅葱・金茶の三面で和紙の折り目を表すモダン菱紋",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkOrigamiShiori(
                        size: markSize,
                        primaryColor: isDark ? Color(wphmHex: 0x3D6287) : WPHeroMarkPalette.ai,
                        secondaryColor: isDark ? Color(wphmHex: 0x6AA0B5) : WPHeroMarkPalette.asagi,
                        accentColor: WPHeroMarkPalette.kin
                    )
                }

                markCard(
                    name: "六、満月と頁",
                    reading: "つきとぺーじ",
                    desc: "藍鉄の夜空に昇る満月と和本を重ねた角丸アイコン案",
                    card: card, fg: fg, sub: sub, line: line
                ) { _ in
                    WPHeroMarkMoonPages(
                        size: markSize,
                        skyColor: WPHeroMarkPalette.nightSky,
                        moonColor: WPHeroMarkPalette.moonGold
                    )
                }

                markCard(
                    name: "七、水引・梅結び紋",
                    reading: "うめむすび",
                    desc: "五弁の輪が連なる紅白水引の梅結びエンブレム",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkMizuhikiUme(
                        size: markSize,
                        primaryColor: isDark ? WPHeroMarkPalette.shuinBright : WPHeroMarkPalette.shuin,
                        secondaryColor: WPHeroMarkPalette.kin
                    )
                }

                markCard(
                    name: "八、活版・魚尾版面",
                    reading: "かっぱんぎょび",
                    desc: "和装本の版心（魚尾）と縦罫線を抽象化した活版書房マーク",
                    card: card, fg: fg, sub: sub, line: line
                ) { isDark in
                    WPHeroMarkKappanGrid(
                        size: markSize,
                        inkColor: isDark ? WPHeroMarkPalette.inkDark : WPHeroMarkPalette.sumi,
                        accentColor: isDark ? WPHeroMarkPalette.shuinBright : WPHeroMarkPalette.shuin
                    )
                }

                Text("よみび 1.0 ・ ヒーローマーク 8案見本帳")
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
                Text("ヒーローマーク 見本帳")
                    .font(.custom("HiraMinProN-W6", size: 22))
                    .foregroundStyle(fg)
                Spacer()
                Text("純図形 × 8案")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(sub)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(Capsule().stroke(line, lineWidth: 1))
            }
            Text("「よみび」のヒーローに置く、画像アセットなしの図形アイコン案。左に白練地、右に墨地での佇まいを並べます。")
                .font(.system(size: 12))
                .foregroundStyle(sub)
                .lineSpacing(3)
        }
    }

    private func controlBar(card: Color, fg: Color, sub: Color, line: Color) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("寸法")
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .foregroundStyle(fg)
                Spacer()
                Picker("寸法", selection: $markSize) {
                    Text("小 52").tag(CGFloat(52))
                    Text("中 68").tag(CGFloat(68))
                    Text("大 84").tag(CGFloat(84))
                }
                .pickerStyle(.segmented)
                .frame(width: 210)
            }

            HStack {
                Text("紙面")
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .foregroundStyle(fg)
                Spacer()
                Picker("紙面", selection: $isDarkChrome) {
                    Text("白練（明）").tag(false)
                    Text("墨色（暗）").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 210)
            }
        }
        .padding(12)
        .background(card)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func markCard<Content: View>(
        name: String,
        reading: String,
        desc: String,
        card: Color,
        fg: Color,
        sub: Color,
        line: Color,
        @ViewBuilder mark: @escaping (Bool) -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(name)
                    .font(.custom("HiraMinProN-W6", size: 14.5))
                    .foregroundStyle(fg)
                Text(reading)
                    .font(.custom("HiraMinProN-W3", size: 10.5))
                    .foregroundStyle(sub)
            }
            Text(desc)
                .font(.system(size: 11.5))
                .foregroundStyle(sub)

            HStack(spacing: 10) {
                heroPreviewTile(isDark: false) { mark(false) }
                heroPreviewTile(isDark: true) { mark(true) }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(card)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func heroPreviewTile<Content: View>(isDark: Bool, @ViewBuilder mark: () -> Content) -> some View {
        let tileBg = isDark ? WPHeroMarkPalette.sumiDark : WPHeroMarkPalette.washiLight
        let tileFg = isDark ? WPHeroMarkPalette.inkDark : WPHeroMarkPalette.inkLight
        let tileSub = isDark ? WPHeroMarkPalette.subDark : WPHeroMarkPalette.subLight
        let tileLine = isDark ? WPHeroMarkPalette.lineDark : WPHeroMarkPalette.lineLight

        return VStack(spacing: 8) {
            mark()
                .frame(height: 86)
            VStack(spacing: 2) {
                Text("よみび")
                    .font(.custom("HiraMinProN-W6", size: 13))
                    .foregroundStyle(tileFg)
                Text(isDark ? "墨色地" : "白練地")
                    .font(.system(size: 9.5))
                    .foregroundStyle(tileSub)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(tileBg)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(tileLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

#Preview {
    WafuPartsHeroMarksGallery()
}
