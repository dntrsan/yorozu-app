import SwiftUI

// MARK: - Private Color Helper & Palette

private extension Color {
    init(wppHex: UInt32, alpha: Double = 1.0) {
        let r = Double((wppHex >> 16) & 0xFF) / 255.0
        let g = Double((wppHex >> 8) & 0xFF) / 255.0
        let b = Double(wppHex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

private enum WPPatternPalette {
    static let washiLight = Color(wppHex: 0xF7F4EC)
    static let washiCardLight = Color(wppHex: 0xFCFBF7)
    static let inkLight = Color(wppHex: 0x1E1C1A)
    static let subInkLight = Color(wppHex: 0x625D56)
    static let hairlineLight = Color(wppHex: 0xE2DDD2)

    static let sumiDark = Color(wppHex: 0x151412)
    static let sumiCardDark = Color(wppHex: 0x1E1C19)
    static let inkDark = Color(wppHex: 0xEFECE4)
    static let subInkDark = Color(wppHex: 0x9C958A)
    static let hairlineDark = Color(wppHex: 0x2F2C27)

    // 伝統色（ライト地用 / ダーク地用）
    static let aiNezu = Color(wppHex: 0x435A6E)
    static let asagiNezu = Color(wppHex: 0x8AA9C2)

    static let rikyuCha = Color(wppHex: 0x6E654A)
    static let kareKusa = Color(wppHex: 0xBDB28E)

    static let tetsuKon = Color(wppHex: 0x2A3847)
    static let ginNezu = Color(wppHex: 0x9CA6B0)

    static let kobaiNezu = Color(wppHex: 0x9E5A5E)
    static let sakuraNezu = Color(wppHex: 0xD49A9E)

    static let shikon = Color(wppHex: 0x4F3B5E)
    static let fujiMurasaki = Color(wppHex: 0xA892BA)

    static let matsuba = Color(wppHex: 0x445C46)
    static let wakatake = Color(wppHex: 0x8EB090)

    static let korozen = Color(wppHex: 0x855E34)
    static let kuchiba = Color(wppHex: 0xCCA878)

    static let susutake = Color(wppHex: 0x5C493E)
    static let tonoko = Color(wppHex: 0xBFA999)
}

private func wppClampedDensity(_ value: CGFloat) -> CGFloat {
    min(max(value, 0.25), 4.0)
}

// MARK: - 1. 青海波（せいがいは）

/// 同心円弧が重なり広がる青海波文様。
/// `drawLayer` 内の `destinationOut` により透過背景でも下層の波が正しく隠れる。
struct WPPatternSeigaiha: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat
    var ringCount: Int

    init(
        color: Color = Color(.sRGB, red: 0.263, green: 0.353, blue: 0.431),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 1.0,
        ringCount: Int = 4
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
        self.ringCount = ringCount
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let radius: CGFloat = 24.0 / safeDensity
            let stepX: CGFloat = radius * 2.0
            let stepY: CGFloat = radius * 0.55
            let rings = max(2, min(ringCount, 6))

            let cols = Int(ceil(size.width / stepX)) + 2
            let rows = Int(ceil(size.height / stepY)) + 3

            context.drawLayer { layer in
                for row in -1...rows {
                    let offsetX: CGFloat = (row % 2 == 0) ? 0.0 : radius
                    let cy = CGFloat(row) * stepY
                    for col in -1...cols {
                        let cx = CGFloat(col) * stepX + offsetX

                        // 手前の波で奥の波をくり抜く（透過背景対応）
                        let maskRect = CGRect(
                            x: cx - radius,
                            y: cy - radius,
                            width: radius * 2.0,
                            height: radius * 2.0
                        )
                        layer.blendMode = .destinationOut
                        layer.fill(Path(ellipseIn: maskRect), with: .color(.black))

                        // 同心円を描く
                        layer.blendMode = .normal
                        var wavePath = Path()
                        for i in 0..<rings {
                            let fraction = 1.0 - (CGFloat(i) / CGFloat(rings)) * 0.78
                            let r = radius * fraction
                            let rect = CGRect(x: cx - r, y: cy - r, width: r * 2.0, height: r * 2.0)
                            wavePath.addEllipse(in: rect)
                        }
                        layer.stroke(wavePath, with: .color(color), lineWidth: lineWidth)
                    }
                }
            }
        }
        .clipped()
    }
}

// MARK: - 2. 麻の葉（あさのは）

/// 正六角形を6つの正三角形に分割し、各重心から頂点へ線を結ぶ麻の葉文様。
struct WPPatternAsanoha: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat

    init(
        color: Color = Color(.sRGB, red: 0.431, green: 0.396, blue: 0.290),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 0.9
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let radius: CGFloat = 24.0 / safeDensity
            let sqrt3: CGFloat = sqrt(3.0)
            let stepX: CGFloat = sqrt3 * radius
            let stepY: CGFloat = 1.5 * radius

            let cols = Int(ceil(size.width / stepX)) + 2
            let rows = Int(ceil(size.height / stepY)) + 2

            var path = Path()
            let angles: [CGFloat] = (0..<6).map { i in
                CGFloat(i) * (.pi / 3.0) - (.pi / 2.0)
            }

            for row in -1...rows {
                let offsetX: CGFloat = (row % 2 == 0) ? 0.0 : stepX * 0.5
                let cy = CGFloat(row) * stepY
                for col in -1...cols {
                    let cx = CGFloat(col) * stepX + offsetX
                    let center = CGPoint(x: cx, y: cy)

                    let vertices: [CGPoint] = angles.map { angle in
                        CGPoint(x: cx + cos(angle) * radius, y: cy + sin(angle) * radius)
                    }

                    for i in 0..<6 {
                        let v1 = vertices[i]
                        let v2 = vertices[(i + 1) % 6]

                        // 六角形の外辺（重複を避けるため上側3辺のみでもよいが単一Pathで統一描画）
                        if i < 3 {
                            path.move(to: v1)
                            path.addLine(to: v2)
                        }

                        // 中心から頂点へ
                        path.move(to: center)
                        path.addLine(to: v1)

                        // 三角形の重心から3頂点へ
                        let gx = (center.x + v1.x + v2.x) / 3.0
                        let gy = (center.y + v1.y + v2.y) / 3.0
                        let centroid = CGPoint(x: gx, y: gy)

                        path.move(to: centroid)
                        path.addLine(to: center)
                        path.move(to: centroid)
                        path.addLine(to: v1)
                        path.move(to: centroid)
                        path.addLine(to: v2)
                    }
                }
            }

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
        .clipped()
    }
}

// MARK: - 3. 市松（いちまつ）

enum WPPatternIchimatsuStyle: Sendable {
    /// 端正な標準の市松
    case classic
    /// 桝の内側に極細の縁取りを添えた「枠市松」
    case framed
}

/// 途切れなく続く繁栄の市松文様。
struct WPPatternIchimatsu: View {
    var color: Color
    var secondaryColor: Color
    var density: CGFloat
    var style: WPPatternIchimatsuStyle

    init(
        color: Color = Color(.sRGB, red: 0.165, green: 0.220, blue: 0.278),
        secondaryColor: Color = .clear,
        density: CGFloat = 1.0,
        style: WPPatternIchimatsuStyle = .classic
    ) {
        self.color = color
        self.secondaryColor = secondaryColor
        self.density = density
        self.style = style
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let cell: CGFloat = 18.0 / safeDensity
            let cols = Int(ceil(size.width / cell)) + 1
            let rows = Int(ceil(size.height / cell)) + 1

            var primaryPath = Path()
            var secondaryPath = Path()
            var framePath = Path()

            for row in 0..<rows {
                for col in 0..<cols {
                    let rect = CGRect(
                        x: CGFloat(col) * cell,
                        y: CGFloat(row) * cell,
                        width: cell,
                        height: cell
                    )
                    if (row + col) % 2 == 0 {
                        primaryPath.addRect(rect)
                    } else {
                        secondaryPath.addRect(rect)
                        if style == .framed {
                            let inset = max(cell * 0.14, 1.5)
                            framePath.addRect(rect.insetBy(dx: inset, dy: inset))
                        }
                    }
                }
            }

            if secondaryColor != .clear {
                context.fill(secondaryPath, with: .color(secondaryColor))
            }
            context.fill(primaryPath, with: .color(color))

            if style == .framed {
                context.stroke(framePath, with: .color(color.opacity(0.45)), lineWidth: 0.7)
            }
        }
        .clipped()
    }
}

// MARK: - 4. 七宝（しっぽう）

/// 円満とご縁が連なる七宝繋ぎ。千鳥に配した等径の円が四弁の花を形づくる。
struct WPPatternShippo: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat
    var showCenterStar: Bool

    init(
        color: Color = Color(.sRGB, red: 0.620, green: 0.353, blue: 0.369),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 1.0,
        showCenterStar: Bool = true
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
        self.showCenterStar = showCenterStar
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let radius: CGFloat = 20.0 / safeDensity
            let step: CGFloat = radius * 2.0

            let cols = Int(ceil(size.width / step)) + 2
            let rows = Int(ceil(size.height / step)) + 2

            var circlePath = Path()
            var starPath = Path()

            for row in -1...rows {
                for col in -1...cols {
                    let cx1 = CGFloat(col) * step
                    let cy1 = CGFloat(row) * step
                    let cx2 = cx1 + radius
                    let cy2 = cy1 + radius

                    circlePath.addEllipse(in: CGRect(
                        x: cx1 - radius,
                        y: cy1 - radius,
                        width: radius * 2.0,
                        height: radius * 2.0
                    ))
                    circlePath.addEllipse(in: CGRect(
                        x: cx2 - radius,
                        y: cy2 - radius,
                        width: radius * 2.0,
                        height: radius * 2.0
                    ))

                    if showCenterStar {
                        let s = radius * 0.14
                        addDiamond(to: &starPath, center: CGPoint(x: cx1, y: cy1), halfSize: s)
                        addDiamond(to: &starPath, center: CGPoint(x: cx2, y: cy2), halfSize: s)
                    }
                }
            }

            context.stroke(circlePath, with: .color(color), lineWidth: lineWidth)
            if showCenterStar {
                context.fill(starPath, with: .color(color.opacity(0.65)))
            }
        }
        .clipped()
    }

    private func addDiamond(to path: inout Path, center: CGPoint, halfSize: CGFloat) {
        path.move(to: CGPoint(x: center.x, y: center.y - halfSize))
        path.addLine(to: CGPoint(x: center.x + halfSize, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + halfSize))
        path.addLine(to: CGPoint(x: center.x - halfSize, y: center.y))
        path.closeSubpath()
    }
}

// MARK: - 5. 矢絣（やがすり）

/// 矢羽根が列ごとに上下互い違いに連なる矢絣文様。
struct WPPatternYagasuri: View {
    var color: Color
    var secondaryColor: Color
    var density: CGFloat

    init(
        color: Color = Color(.sRGB, red: 0.310, green: 0.231, blue: 0.369),
        secondaryColor: Color = .clear,
        density: CGFloat = 1.0
    ) {
        self.color = color
        self.secondaryColor = secondaryColor
        self.density = density
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let colWidth: CGFloat = 20.0 / safeDensity
            let halfWidth: CGFloat = colWidth * 0.5
            let rowHeight: CGFloat = colWidth * 2.0
            let halfRow: CGFloat = rowHeight * 0.5
            let slant: CGFloat = colWidth * 0.55

            let cols = Int(ceil(size.width / colWidth)) + 1
            let rows = Int(ceil(size.height / rowHeight)) + 2

            var primaryPath = Path()
            var secondaryPath = Path()

            for col in 0..<cols {
                let x0 = CGFloat(col) * colWidth
                let xm = x0 + halfWidth
                let x1 = x0 + colWidth
                let pointsUp = (col % 2 == 0)

                for row in -1...rows {
                    let y = CGFloat(row) * rowHeight

                    if pointsUp {
                        // 左羽根（主色）
                        addParallelogram(
                            to: &primaryPath,
                            p1: CGPoint(x: x0, y: y + slant),
                            p2: CGPoint(x: xm, y: y),
                            p3: CGPoint(x: xm, y: y + halfRow),
                            p4: CGPoint(x: x0, y: y + halfRow + slant)
                        )
                        // 右羽根（半段ずらし・主色）
                        addParallelogram(
                            to: &primaryPath,
                            p1: CGPoint(x: xm, y: y + halfRow),
                            p2: CGPoint(x: x1, y: y + halfRow + slant),
                            p3: CGPoint(x: x1, y: y + rowHeight + slant),
                            p4: CGPoint(x: xm, y: y + rowHeight)
                        )
                        if secondaryColor != .clear {
                            addParallelogram(
                                to: &secondaryPath,
                                p1: CGPoint(x: xm, y: y),
                                p2: CGPoint(x: x1, y: y + slant),
                                p3: CGPoint(x: x1, y: y + halfRow + slant),
                                p4: CGPoint(x: xm, y: y + halfRow)
                            )
                        }
                    } else {
                        // 下向き左羽根（主色）
                        addParallelogram(
                            to: &primaryPath,
                            p1: CGPoint(x: x0, y: y),
                            p2: CGPoint(x: xm, y: y + slant),
                            p3: CGPoint(x: xm, y: y + halfRow + slant),
                            p4: CGPoint(x: x0, y: y + halfRow)
                        )
                        // 下向き右羽根（半段ずらし・主色）
                        addParallelogram(
                            to: &primaryPath,
                            p1: CGPoint(x: xm, y: y + halfRow + slant),
                            p2: CGPoint(x: x1, y: y + halfRow),
                            p3: CGPoint(x: x1, y: y + rowHeight),
                            p4: CGPoint(x: xm, y: y + rowHeight + slant)
                        )
                        if secondaryColor != .clear {
                            addParallelogram(
                                to: &secondaryPath,
                                p1: CGPoint(x: xm, y: y + slant),
                                p2: CGPoint(x: x1, y: y),
                                p3: CGPoint(x: x1, y: y + halfRow),
                                p4: CGPoint(x: xm, y: y + halfRow + slant)
                            )
                        }
                    }
                }
            }

            if secondaryColor != .clear {
                context.fill(secondaryPath, with: .color(secondaryColor))
            }
            context.fill(primaryPath, with: .color(color))
        }
        .clipped()
    }

    private func addParallelogram(
        to path: inout Path,
        p1: CGPoint,
        p2: CGPoint,
        p3: CGPoint,
        p4: CGPoint
    ) {
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.closeSubpath()
    }
}

// MARK: - 6. 亀甲（きっこう）

/// 長寿の象徴である正六角形の亀甲文様。二重線の「子持ち亀甲」にも対応。
struct WPPatternKikkou: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat
    var isDouble: Bool

    init(
        color: Color = Color(.sRGB, red: 0.267, green: 0.361, blue: 0.275),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 1.0,
        isDouble: Bool = true
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
        self.isDouble = isDouble
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let radius: CGFloat = 20.0 / safeDensity
            let sqrt3: CGFloat = sqrt(3.0)
            let stepX: CGFloat = sqrt3 * radius
            let stepY: CGFloat = 1.5 * radius

            let cols = Int(ceil(size.width / stepX)) + 2
            let rows = Int(ceil(size.height / stepY)) + 2

            let angles: [CGFloat] = (0..<6).map { i in
                CGFloat(i) * (.pi / 3.0) - (.pi / 2.0)
            }

            var outerPath = Path()
            var innerPath = Path()

            for row in -1...rows {
                let offsetX: CGFloat = (row % 2 == 0) ? 0.0 : stepX * 0.5
                let cy = CGFloat(row) * stepY
                for col in -1...cols {
                    let cx = CGFloat(col) * stepX + offsetX
                    addHexagon(to: &outerPath, cx: cx, cy: cy, radius: radius, angles: angles, onlyTopThreeEdges: true)
                    if isDouble {
                        addHexagon(to: &innerPath, cx: cx, cy: cy, radius: radius * 0.74, angles: angles, onlyTopThreeEdges: false)
                    }
                }
            }

            context.stroke(
                outerPath,
                with: .color(color),
                style: StrokeStyle(lineWidth: lineWidth, lineJoin: .miter)
            )
            if isDouble {
                context.stroke(
                    innerPath,
                    with: .color(color.opacity(0.68)),
                    style: StrokeStyle(lineWidth: lineWidth * 0.8, lineJoin: .miter)
                )
            }
        }
        .clipped()
    }

    private func addHexagon(
        to path: inout Path,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        angles: [CGFloat],
        onlyTopThreeEdges: Bool
    ) {
        let pts: [CGPoint] = angles.map { a in
            CGPoint(x: cx + cos(a) * radius, y: cy + sin(a) * radius)
        }
        if onlyTopThreeEdges {
            for i in 0..<3 {
                path.move(to: pts[i])
                path.addLine(to: pts[(i + 1) % 6])
            }
        } else {
            path.move(to: pts[0])
            for i in 1..<6 {
                path.addLine(to: pts[i])
            }
            path.closeSubpath()
        }
    }
}

// MARK: - 7. 紗綾形（さやがた）

/// 斜め45°に傾けた卍（まんじ）が途切れなく連なる紗綾形文様。
/// 直交格子上の並進ベクトル (3u, u) / (-u, 3u) で重複なく組み立て、45°回転して描画する。
struct WPPatternSayagata: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat

    init(
        color: Color = Color(.sRGB, red: 0.522, green: 0.369, blue: 0.204),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 1.15
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let u: CGFloat = 8.5 / safeDensity
            let invSqrt2: CGFloat = 1.0 / sqrt(2.0)

            // 描画領域を45°逆回転で覆うために十分な格子範囲を算出
            let diagonal = hypot(size.width, size.height)
            let span = Int(ceil(diagonal / (u * 3.0))) + 3

            var path = Path()

            func rotate45(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(
                    x: (x - y) * invSqrt2 + size.width * 0.5,
                    y: (x + y) * invSqrt2 + size.height * 0.5
                )
            }

            func addSegment(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
                path.move(to: rotate45(x1, y1))
                path.addLine(to: rotate45(x2, y2))
            }

            for m in -span...span {
                for n in -span...span {
                    let cx = (CGFloat(m) * 3.0 - CGFloat(n)) * u
                    let cy = (CGFloat(m) + CGFloat(n) * 3.0) * u

                    // 画面外を大きく外れるセルを間引く
                    let center = rotate45(cx, cy)
                    let margin = u * 5.0
                    if center.x < -margin || center.x > size.width + margin ||
                       center.y < -margin || center.y > size.height + margin {
                        continue
                    }

                    // 中央十字
                    addSegment(cx - u, cy, cx + u, cy)
                    addSegment(cx, cy - u, cx, cy + u)

                    // 4方向の折れ腕（長さ 2u）
                    addSegment(cx + u, cy, cx + u, cy + 2.0 * u)
                    addSegment(cx, cy + u, cx - 2.0 * u, cy + u)
                    addSegment(cx - u, cy, cx - u, cy - 2.0 * u)
                    addSegment(cx, cy - u, cx + 2.0 * u, cy - u)
                }
            }

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .square, lineJoin: .miter)
            )
        }
        .clipped()
    }
}

// MARK: - 8. 籠目（かごめ）

/// 3方向の平行線が正六角形と正三角形（六芒星）を織りなす竹籠の籠目文様。
struct WPPatternKagome: View {
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat
    var isDoubleLine: Bool

    init(
        color: Color = Color(.sRGB, red: 0.361, green: 0.286, blue: 0.243),
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 0.95,
        isDoubleLine: Bool = false
    ) {
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
        self.isDoubleLine = isDoubleLine
    }

    var body: some View {
        Canvas { context, size in
            let safeDensity = wppClampedDensity(density)
            let edge: CGFloat = 14.0 / safeDensity
            let sqrt3: CGFloat = sqrt(3.0)
            let bandSpacing: CGFloat = sqrt3 * edge
            let offsets: [CGFloat] = isDoubleLine ? [-lineWidth * 1.35, lineWidth * 1.35] : [0.0]

            var path = Path()

            // 1. 水平線（半周期ずらしで3線交点を回避）
            let hCount = Int(ceil(size.height / bandSpacing)) + 2
            for k in -1...hCount {
                let baseY = (CGFloat(k) + 0.5) * bandSpacing
                for shift in offsets {
                    let y = baseY + shift
                    path.move(to: CGPoint(x: -edge, y: y))
                    path.addLine(to: CGPoint(x: size.width + edge, y: y))
                }
            }

            // 2. +60° 線: y = sqrt3 * (x - 2 * m * edge)
            let xSpan = size.width + size.height / sqrt3
            let mMin = Int(floor(-size.height / (2.0 * sqrt3 * edge))) - 2
            let mMax = Int(ceil(xSpan / (2.0 * edge))) + 2
            for m in mMin...mMax {
                let baseX0 = 2.0 * CGFloat(m) * edge
                for shift in offsets {
                    // 法線シフトを x 切片へ換算（shift / cos(30°) = shift * 2 / sqrt3）
                    let x0 = baseX0 + shift * (2.0 / sqrt3)
                    let pStart = CGPoint(x: x0 - edge, y: -sqrt3 * edge)
                    let pEnd = CGPoint(
                        x: x0 + (size.height + edge * sqrt3) / sqrt3,
                        y: size.height + edge * sqrt3
                    )
                    path.move(to: pStart)
                    path.addLine(to: pEnd)
                }
            }

            // 3. -60° 線: y = sqrt3 * (2 * n * edge - x)
            let nMin = -2
            let nMax = Int(ceil((size.width + size.height / sqrt3) / (2.0 * edge))) + 2
            for n in nMin...nMax {
                let baseX0 = 2.0 * CGFloat(n) * edge
                for shift in offsets {
                    let x0 = baseX0 + shift * (2.0 / sqrt3)
                    let pStart = CGPoint(x: x0 + edge, y: -sqrt3 * edge)
                    let pEnd = CGPoint(
                        x: x0 - (size.height + edge * sqrt3) / sqrt3,
                        y: size.height + edge * sqrt3
                    )
                    path.move(to: pStart)
                    path.addLine(to: pEnd)
                }
            }

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
            )
        }
        .clipped()
    }
}

// MARK: - 汎用ラッパー（一覧や動的切替用）

enum WPPatternKind: String, CaseIterable, Identifiable, Sendable {
    case seigaiha = "青海波"
    case asanoha = "麻の葉"
    case ichimatsu = "市松"
    case shippo = "七宝"
    case yagasuri = "矢絣"
    case kikkou = "亀甲"
    case sayagata = "紗綾形"
    case kagome = "籠目"

    var id: String { rawValue }

    var reading: String {
        switch self {
        case .seigaiha: return "せいがいは"
        case .asanoha: return "あさのは"
        case .ichimatsu: return "いちまつ"
        case .shippo: return "しっぽう"
        case .yagasuri: return "やがすり"
        case .kikkou: return "きっこう"
        case .sayagata: return "さやがた"
        case .kagome: return "かごめ"
        }
    }

    var subtitle: String {
        switch self {
        case .seigaiha: return "穏やかな波が無限に広がる吉祥文様"
        case .asanoha: return "真っ直ぐ伸びる麻の葉の端正な幾何学"
        case .ichimatsu: return "途切れず続く格子。見出し帯や背景の地に"
        case .shippo: return "円満とご縁が四方に連なる輪違い文様"
        case .yagasuri: return "矢羽根を互い違いに配した粋な縦リズム"
        case .kikkou: return "長寿を願う子持ち六角形の静かな骨格"
        case .sayagata: return "斜め卍が絶え間なく続く格式ある地紋"
        case .kagome: return "三方向の竹ひごが六芒星を編む魔除け文様"
        }
    }
}

struct WPPatternView: View {
    var kind: WPPatternKind
    var color: Color
    var density: CGFloat
    var lineWidth: CGFloat

    init(
        kind: WPPatternKind,
        color: Color,
        density: CGFloat = 1.0,
        lineWidth: CGFloat = 1.0
    ) {
        self.kind = kind
        self.color = color
        self.density = density
        self.lineWidth = lineWidth
    }

    var body: some View {
        switch kind {
        case .seigaiha:
            WPPatternSeigaiha(color: color, density: density, lineWidth: lineWidth)
        case .asanoha:
            WPPatternAsanoha(color: color, density: density, lineWidth: lineWidth)
        case .ichimatsu:
            WPPatternIchimatsu(color: color, density: density, style: .framed)
        case .shippo:
            WPPatternShippo(color: color, density: density, lineWidth: lineWidth)
        case .yagasuri:
            WPPatternYagasuri(color: color, density: density)
        case .kikkou:
            WPPatternKikkou(color: color, density: density, lineWidth: lineWidth)
        case .sayagata:
            WPPatternSayagata(color: color, density: density, lineWidth: lineWidth)
        case .kagome:
            WPPatternKagome(color: color, density: density, lineWidth: lineWidth)
        }
    }
}

// MARK: - 見本帳 Gallery View

struct WafuPartsPatternsGallery: View {
    @State private var density: CGFloat = 1.0
    @State private var isDarkChrome: Bool = false

    init() {}

    var body: some View {
        let bg = isDarkChrome ? WPPatternPalette.sumiDark : WPPatternPalette.washiLight
        let fg = isDarkChrome ? WPPatternPalette.inkDark : WPPatternPalette.inkLight
        let sub = isDarkChrome ? WPPatternPalette.subInkDark : WPPatternPalette.subInkLight
        let line = isDarkChrome ? WPPatternPalette.hairlineDark : WPPatternPalette.hairlineLight

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection(fg: fg, sub: sub, line: line)
                controlsSection(fg: fg, sub: sub, line: line)

                ForEach(WPPatternKind.allCases) { kind in
                    patternSampleCard(kind: kind, fg: fg, sub: sub, line: line)
                }

                Text("よみび 1.0 ・ 背景の伝統文様 8種見本帳")
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(sub)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
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
                Text("伝統文様 見本帳")
                    .font(.custom("HiraMinProN-W6", size: 22))
                    .foregroundStyle(fg)
                Spacer()
                Text("Canvas × 8種")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(sub)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(Capsule().stroke(line, lineWidth: 1))
            }
            Text("色と密度を引数で変えられる背景地紋。左に和紙地、右に墨地を並べて視認性を確かめます。")
                .font(.system(size: 12))
                .foregroundStyle(sub)
                .lineSpacing(3)
        }
    }

    private func controlsSection(fg: Color, sub: Color, line: Color) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("密度")
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .foregroundStyle(fg)
                Slider(value: $density.wafuHaptic(), in: 0.65...1.75, step: 0.05)
                    .tint(isDarkChrome ? WPPatternPalette.asagiNezu : WPPatternPalette.aiNezu)
                Text(String(format: "%.2fx", density))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(sub)
                    .frame(width: 44, alignment: .trailing)
            }
            HStack {
                Text("見本帳の紙面")
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
        .padding(14)
        .background(isDarkChrome ? WPPatternPalette.sumiCardDark : WPPatternPalette.washiCardLight)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func patternSampleCard(kind: WPPatternKind, fg: Color, sub: Color, line: Color) -> some View {
        let pair = colors(for: kind)
        let cardBg = isDarkChrome ? WPPatternPalette.sumiCardDark : WPPatternPalette.washiCardLight

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(kind.rawValue)
                    .font(.custom("HiraMinProN-W6", size: 16))
                    .foregroundStyle(fg)
                Text(kind.reading)
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .foregroundStyle(sub)
                Spacer()
                Text(pair.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(sub)
            }

            Text(kind.subtitle)
                .font(.system(size: 11.5))
                .foregroundStyle(sub)

            HStack(spacing: 10) {
                // ライト地スウォッチ
                ZStack(alignment: .bottomLeading) {
                    WPPatternPalette.washiLight
                    WPPatternView(
                        kind: kind,
                        color: pair.light.opacity(fillOpacity(for: kind, isDark: false)),
                        density: density,
                        lineWidth: 0.95
                    )
                    swatchOverlayLabel(
                        title: "よみび",
                        caption: "白練地",
                        isDark: false
                    )
                }
                .frame(height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(WPPatternPalette.hairlineLight, lineWidth: 1))

                // ダーク地スウォッチ
                ZStack(alignment: .bottomLeading) {
                    WPPatternPalette.sumiDark
                    WPPatternView(
                        kind: kind,
                        color: pair.dark.opacity(fillOpacity(for: kind, isDark: true)),
                        density: density,
                        lineWidth: 0.95
                    )
                    swatchOverlayLabel(
                        title: "よみび",
                        caption: "墨色地",
                        isDark: true
                    )
                }
                .frame(height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(WPPatternPalette.hairlineDark, lineWidth: 1))
            }
        }
        .padding(14)
        .background(cardBg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func swatchOverlayLabel(title: String, caption: String, isDark: Bool) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 11))
            Text("・\(caption)")
                .font(.system(size: 9.5))
                .opacity(0.75)
        }
        .foregroundStyle(isDark ? WPPatternPalette.inkDark : WPPatternPalette.inkLight)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (isDark ? WPPatternPalette.sumiDark : WPPatternPalette.washiLight)
                .opacity(0.84)
        )
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(7)
    }

    private func fillOpacity(for kind: WPPatternKind, isDark: Bool) -> Double {
        switch kind {
        case .ichimatsu, .yagasuri:
            return isDark ? 0.22 : 0.16
        default:
            return isDark ? 0.42 : 0.36
        }
    }

    private func colors(for kind: WPPatternKind) -> (light: Color, dark: Color, name: String) {
        switch kind {
        case .seigaiha: return (WPPatternPalette.aiNezu, WPPatternPalette.asagiNezu, "藍鼠 / 浅葱鼠")
        case .asanoha: return (WPPatternPalette.rikyuCha, WPPatternPalette.kareKusa, "利休茶 / 枯草")
        case .ichimatsu: return (WPPatternPalette.tetsuKon, WPPatternPalette.ginNezu, "鉄紺 / 銀鼠")
        case .shippo: return (WPPatternPalette.kobaiNezu, WPPatternPalette.sakuraNezu, "紅梅鼠 / 桜鼠")
        case .yagasuri: return (WPPatternPalette.shikon, WPPatternPalette.fujiMurasaki, "紫紺 / 藤紫")
        case .kikkou: return (WPPatternPalette.matsuba, WPPatternPalette.wakatake, "松葉 / 若竹")
        case .sayagata: return (WPPatternPalette.korozen, WPPatternPalette.kuchiba, "黄櫨染 / 朽葉")
        case .kagome: return (WPPatternPalette.susutake, WPPatternPalette.tonoko, "煤竹 / 砥粉")
        }
    }
}

#Preview {
    WafuPartsPatternsGallery()
}
