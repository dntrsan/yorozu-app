import SwiftUI

private func WPHeadingColor(_ hex: UInt32) -> Color {
    Color(
        red: Double((hex >> 16) & 255) / 255,
        green: Double((hex >> 8) & 255) / 255,
        blue: Double(hex & 255) / 255
    )
}

private struct WPHeadingDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

private func WPHeadingUpperSemiArc(centerX: CGFloat, baseY: CGFloat, radius: CGFloat) -> Path {
    let k = radius * 0.55228475
    return Path { p in
        p.move(to: CGPoint(x: centerX - radius, y: baseY))
        p.addCurve(
            to: CGPoint(x: centerX, y: baseY - radius),
            control1: CGPoint(x: centerX - radius, y: baseY - k),
            control2: CGPoint(x: centerX - k, y: baseY - radius)
        )
        p.addCurve(
            to: CGPoint(x: centerX + radius, y: baseY),
            control1: CGPoint(x: centerX + k, y: baseY - radius),
            control2: CGPoint(x: centerX + radius, y: baseY - k)
        )
    }
}

// 01 墨流し見出し（章見出し）
struct WPHeadingInkRule: View {
    var title: String
    var eyebrow: String? = nil
    var ink: Color = WPHeadingColor(0x2F3436)
    var accent: Color = WPHeadingColor(0xA84438)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let eyebrow {
                HStack(spacing: 10) {
                    Text(eyebrow)
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(ink.opacity(0.65))
                        .layoutPriority(1)
                    Rectangle()
                        .fill(ink.opacity(0.22))
                        .frame(height: 0.5)
                }
            }
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 21))
                .lineSpacing(5)
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 0) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 4)
                Spacer().frame(width: 6)
                Rectangle()
                    .fill(ink)
                    .frame(width: 30, height: 1)
                Rectangle()
                    .fill(ink.opacity(0.22))
                    .frame(height: 0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// 02 題箋見出し（縦書き札付きの大見出し）
struct WPHeadingVerticalTag: View {
    var title: String
    var tag: String
    var subtitle: String? = nil
    var ink: Color = WPHeadingColor(0x2F3436)
    var tagGround: Color = WPHeadingColor(0xEAE3D2)
    var tagInk: Color = WPHeadingColor(0x5A4C38)

    var body: some View {
        let chars = Array(tag).map(String.init)
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 1) {
                ForEach(Array(chars.enumerated()), id: \.offset) { _, ch in
                    Text(ch)
                        .font(.custom("HiraMinProN-W6", size: 10))
                }
            }
            .foregroundStyle(tagInk)
            .padding(.vertical, 7)
            .frame(width: 24)
            .background(tagGround)
            .overlay(
                Rectangle()
                    .strokeBorder(tagInk.opacity(0.35), lineWidth: 0.6)
                    .padding(2.5)
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("HiraMinProN-W6", size: 19))
                    .lineSpacing(4)
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .lineSpacing(4)
                        .foregroundStyle(ink.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// 03 霞帯見出し（淡い帯と二重縦線の見出し）
struct WPHeadingMistBand: View {
    var title: String
    var detail: String? = nil
    var indigo: Color = WPHeadingColor(0x2E4F5E)
    var ink: Color = WPHeadingColor(0x2F3436)

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 17))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            if let detail {
                Text(detail)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.4)
                    .foregroundStyle(indigo)
            }
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .padding(.trailing, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [indigo.opacity(0.11), indigo.opacity(0.02)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(alignment: .leading) {
            HStack(spacing: 2) {
                Rectangle().fill(indigo).frame(width: 3)
                Rectangle().fill(indigo.opacity(0.38)).frame(width: 0.7)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// 04 菱点小見出し（菱印と点線の小見出し）
struct WPHeadingSubheadDiamond: View {
    var title: String
    var index: String? = nil
    var ink: Color = WPHeadingColor(0x2F3436)
    var accent: Color = WPHeadingColor(0x5C6B52)

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(accent)
                .frame(width: 6, height: 6)
                .rotationEffect(.degrees(45))
            if let index {
                Text(index)
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .foregroundStyle(accent)
                    .layoutPriority(1)
            }
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 15))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            WPHeadingDottedLine()
                .stroke(ink.opacity(0.32), style: StrokeStyle(lineWidth: 0.8, dash: [2, 4]))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// 05 割注小見出し（上下罫と右添え語の小見出し）
struct WPHeadingSplitSubhead: View {
    var title: String
    var note: String? = nil
    var ink: Color = WPHeadingColor(0x2F3436)

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ink.opacity(0.22))
                .frame(height: 0.5)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(title)
                    .font(.custom("HiraMinProN-W6", size: 14))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if let note {
                    Text(note)
                        .font(.system(size: 10))
                        .tracking(0.6)
                        .foregroundStyle(ink.opacity(0.66))
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(.vertical, 9)
            Rectangle()
                .fill(ink.opacity(0.55))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// 06 組菱罫（中央に重ね菱を置く飾り罫）
struct WPHeadingDiamondDivider: View {
    var ink: Color = WPHeadingColor(0x2F3436)
    var accent: Color = WPHeadingColor(0x9E5347)

    var body: some View {
        HStack(spacing: 10) {
            LinearGradient(
                colors: [ink.opacity(0.04), ink.opacity(0.35)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.7)
            Canvas { context, _ in
                let leftDot = Path(ellipseIn: CGRect(x: 2.75, y: 5.75, width: 2.5, height: 2.5))
                let rightDot = Path(ellipseIn: CGRect(x: 28.75, y: 5.75, width: 2.5, height: 2.5))
                context.fill(leftDot, with: .color(ink.opacity(0.45)))
                context.fill(rightDot, with: .color(ink.opacity(0.45)))

                var outer = Path()
                outer.move(to: CGPoint(x: 17, y: 1))
                outer.addLine(to: CGPoint(x: 23, y: 7))
                outer.addLine(to: CGPoint(x: 17, y: 13))
                outer.addLine(to: CGPoint(x: 11, y: 7))
                outer.closeSubpath()
                context.stroke(outer, with: .color(ink.opacity(0.55)), lineWidth: 0.8)

                var inner = Path()
                inner.move(to: CGPoint(x: 17, y: 4))
                inner.addLine(to: CGPoint(x: 20, y: 7))
                inner.addLine(to: CGPoint(x: 17, y: 10))
                inner.addLine(to: CGPoint(x: 14, y: 7))
                inner.closeSubpath()
                context.fill(inner, with: .color(accent))
            }
            .frame(width: 34, height: 14)
            LinearGradient(
                colors: [ink.opacity(0.35), ink.opacity(0.04)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .accessibilityHidden(true)
    }
}

// 07 青海波罫（一段の青海波が左右へ溶ける飾り罫）
struct WPHeadingSeigaihaDivider: View {
    var ink: Color = WPHeadingColor(0x4A636E)
    var height: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            let unit: CGFloat = 20
            let count = Int((size.width / unit).rounded(.up)) + 2
            let baseY = size.height - 1
            for i in 0..<count {
                let cx = CGFloat(i) * unit
                context.stroke(
                    WPHeadingUpperSemiArc(centerX: cx, baseY: baseY, radius: 10),
                    with: .color(ink.opacity(0.5)),
                    lineWidth: 0.9
                )
                context.stroke(
                    WPHeadingUpperSemiArc(centerX: cx, baseY: baseY, radius: 6.2),
                    with: .color(ink.opacity(0.35)),
                    lineWidth: 0.7
                )
                context.stroke(
                    WPHeadingUpperSemiArc(centerX: cx, baseY: baseY, radius: 2.6),
                    with: .color(ink.opacity(0.25)),
                    lineWidth: 0.6
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .mask(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .clear, location: 0),
                    Gradient.Stop(color: .black, location: 0.14),
                    Gradient.Stop(color: .black, location: 0.86),
                    Gradient.Stop(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.vertical, 6)
        .accessibilityHidden(true)
    }
}

// 08 括り文字罫（ことばを挟む区切り線）
struct WPHeadingLabeledDivider: View {
    var label: String
    var ink: Color = WPHeadingColor(0x2F3436)
    var accent: Color = WPHeadingColor(0x566B73)

    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(ink.opacity(0.24))
                .frame(height: 0.6)
            HStack(spacing: 8) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 1, height: 9)
                Text(label)
                    .font(.custom("HiraMinProN-W3", size: 11))
                    .tracking(2.5)
                    .foregroundStyle(ink.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Rectangle()
                    .fill(accent)
                    .frame(width: 1, height: 9)
            }
            .layoutPriority(1)
            Rectangle()
                .fill(ink.opacity(0.24))
                .frame(height: 0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct WafuPartsHeadingsGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("よみび  /  部品見本帳  04")
                        .font(.system(size: 11))
                        .tracking(2)
                    Text("文を分け、間をつくる。")
                        .font(.custom("HiraMinProN-W6", size: 28))
                    Text("見出しと区切り 八景  /  HEADINGS")
                        .font(.system(size: 11))
                        .tracking(1.6)
                    Text("見出し、小見出し、飾り罫。余白に息つぎを。")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)

                specimen("01  墨流し見出し", "朱の小さな角点と、強弱をつけた細罫。章の冒頭に。") { dark in
                    WPHeadingInkRule(
                        title: "ウェブの文章を、\n本のように読む",
                        eyebrow: "設定のはじめに",
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436),
                        accent: WPHeadingColor(dark ? 0xD26D61 : 0xA84438)
                    )
                }

                specimen("02  題箋見出し", "和本の縦書き札を左に立て、手順の始まりを締める。") { dark in
                    WPHeadingVerticalTag(
                        title: "よみびを有効にする",
                        tag: "手順",
                        subtitle: "四つの手順で、いつもの記事が整います",
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436),
                        tagGround: WPHeadingColor(dark ? 0x35393D : 0xEAE3D2),
                        tagInk: WPHeadingColor(dark ? 0xD6C7AA : 0x5A4C38)
                    )
                }

                specimen("03  霞帯見出し", "藍の二重縦線と淡く溶ける帯。機能のまとまりに。") { dark in
                    WPHeadingMistBand(
                        title: "よみびで変わること",
                        detail: "三つの働き",
                        indigo: WPHeadingColor(dark ? 0x89AFC0 : 0x2E4F5E),
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436)
                    )
                }

                specimen("04  菱点小見出し", "苔色の小さな菱と点線。注意書きや節の頭に。") { dark in
                    WPHeadingSubheadDiamond(
                        title: "サイトごとに許可が要る",
                        index: "一、",
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436),
                        accent: WPHeadingColor(dark ? 0x9CB08E : 0x5C6B52)
                    )
                }

                specimen("05  割注小見出し", "上下の細罫で挟み、右端に短い補足を添える。") { dark in
                    WPHeadingSplitSubhead(
                        title: "手順 四の要点",
                        note: "ここで初めて本文が整う",
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436)
                    )
                }

                specimen("06  組菱罫", "重ね菱を中央に据えた飾り罫。場面の切り替えに。") { dark in
                    WPHeadingDiamondDivider(
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436),
                        accent: WPHeadingColor(dark ? 0xCF887B : 0x9E5347)
                    )
                }

                specimen("07  青海波罫", "一段の波文が左右に溶ける。足元の余韻づくりに。") { dark in
                    WPHeadingSeigaihaDivider(
                        ink: WPHeadingColor(dark ? 0x99B6C2 : 0x4A636E)
                    )
                }

                specimen("08  括り文字罫", "細い縦棒でことばを挟む、意味を持った区切り。") { dark in
                    WPHeadingLabeledDivider(
                        label: "よみびの設定",
                        ink: WPHeadingColor(dark ? 0xE4E5E2 : 0x2F3436),
                        accent: WPHeadingColor(dark ? 0x9AB2BC : 0x566B73)
                    )
                }

                Text("よみび 1.0 ・ ことばの境目に、静かな間を。")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: 390)
        }
        .background(WPHeadingColor(0xF3F0EA))
        .foregroundStyle(WPHeadingColor(0x2F3436))
        .preferredColorScheme(.light)
    }

    private func specimen<V: View>(_ title: String, _ note: String, @ViewBuilder content: (Bool) -> V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("HiraMinProN-W6", size: 19))
            Text(note)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            ForEach([false, true], id: \.self) { dark in
                VStack(alignment: .leading, spacing: 14) {
                    Text(dark ? "墨地" : "白地")
                        .font(.system(size: 9))
                        .tracking(2)
                        .foregroundStyle(WPHeadingColor(dark ? 0xBCC0BE : 0x6C706E))
                    content(dark)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WPHeadingColor(dark ? 0x232629 : 0xFCFBF7))
            }
        }
    }
}

#Preview { WafuPartsHeadingsGallery() }
