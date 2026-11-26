import SwiftUI

private enum Wafu07Palette {
    static let paper = Color(red: 245.0 / 255, green: 237.0 / 255, blue: 218.0 / 255)
    static let ink = Color(red: 15.0 / 255, green: 48.0 / 255, blue: 82.0 / 255)
    static let blue = Color(red: 38.0 / 255, green: 92.0 / 255, blue: 130.0 / 255)
    static let mist = Color(red: 161.0 / 255, green: 186.0 / 255, blue: 186.0 / 255)
    static let seal = Color(red: 166.0 / 255, green: 59.0 / 255, blue: 43.0 / 255)
}

struct Wafu07Screen: View {
    private enum ExtState { case on, off, checking }
    @State private var state: ExtState = .on { didSet { WafuHaptics.tap() } }
    private var stateTitle: String {
        switch state {
        case .on: return "拡張はオンです"
        case .off: return "拡張はオフです"
        case .checking: return "拡張を確認中です"
        }
    }

    private var stateDetail: String {
        switch state {
        case .on: return "読む準備ができました"
        case .off: return "手順②でオンにしてください"
        case .checking: return "拡張の状態を確認しています"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                VStack(alignment: .leading, spacing: 30) {
                    status
                    guide
                    notice
                    safariLink
                    features
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)
                .padding(.bottom, 34)
                footer
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu07Palette.paper)
        .foregroundStyle(Wafu07Palette.ink)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("よみび支度帖")
                Spacer()
                Text("〇七 / 波の巻")
            }
            .font(.system(size: 11, weight: .semibold))
            .tracking(2)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .overlay(alignment: .bottom) { Rectangle().frame(height: 2) }

            HStack(alignment: .center, spacing: 18) {
                Wafu07Mark().frame(width: 65, height: 65)
                Text("よみび")
                    .font(.custom("HiraMinProN-W6", size: 48, relativeTo: .largeTitle))
                    .tracking(5)
                Spacer(minLength: 0)
                Text("読む\n道具")
                    .font(.custom("HiraMinProN-W6", size: 12))
                    .lineSpacing(3)
                    .padding(7)
                    .foregroundStyle(Wafu07Palette.seal)
                    .overlay(Rectangle().stroke(Wafu07Palette.seal, lineWidth: 1.5))
                    .rotationEffect(.degrees(-4))
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)

            Text("ウェブの文章を、本のように読む")
                .font(.custom("HiraMinProN-W3", size: 15, relativeTo: .body))
                .padding(.horizontal, 24)
                .padding(.top, 17)

            HStack(spacing: 8) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .overlay(Rectangle().stroke(Wafu07Palette.ink.opacity(0.45)))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            ZStack {
                Wafu07Seigaiha().opacity(0.3)
                Wafu07Wave()
                    .fill(Wafu07Palette.mist)
                    .offset(x: 5, y: -5)
                Wafu07Wave().fill(Wafu07Palette.blue)
                Wafu07Wave().stroke(Wafu07Palette.ink, lineWidth: 3)
                Wafu07WaveLines().stroke(Wafu07Palette.paper, lineWidth: 2)
            }
            .frame(height: 100)
            .clipped()
            .padding(.top, 20)
            .accessibilityHidden(true)
        }
    }

    private var status: some View {
        Button {
            switch state {
            case .on: state = .off
            case .off: state = .checking
            case .checking: state = .on
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: state == .on ? "checkmark.circle.fill" : state == .off ? "minus.circle" : "ellipsis.circle")
                    .font(.system(size: 25))
                VStack(alignment: .leading, spacing: 6) {
                    Text(stateTitle).font(.custom("HiraMinProN-W6", size: 19, relativeTo: .headline))
                    Text(stateDetail).font(.system(size: 11))
                }
                Spacer(minLength: 0)
                Text(state == .on ? "ON" : state == .off ? "OFF" : "…")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Wafu07Palette.paper)
            .overlay(Rectangle().stroke(Wafu07Palette.ink, lineWidth: 2))
            .background(Wafu07Palette.mist.offset(x: 4, y: 4))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(stateTitle)。\(stateDetail)")
        .accessibilityHint("タップで表示サンプルの状態を切り替えます")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("読むまで、四つ。")
                    .font(.custom("HiraMinProN-W6", size: 24, relativeTo: .title2))
                Spacer()
                Text("はじめの支度").font(.system(size: 10)).tracking(1)
            }
            .padding(.bottom, 12)
            Wafu07Step(number: "一", title: "設定から、Safariへ", detail: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
            Wafu07Step(number: "二", title: "「よみび」をオンにする", detail: nil, note: nil)
            Wafu07Step(number: "三", title: "Safari で好きな記事を開く", detail: nil, note: nil)
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("四").font(.custom("HiraMinProN-W6", size: 25))
                    Spacer()
                    Text("ここで本文が整います")
                        .font(.system(size: 10, weight: .semibold)).tracking(1)
                }
                HStack(spacing: 10) {
                    Text("ぁあ")
                        .font(.custom("HiraMinProN-W6", size: 23))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Wafu07Palette.paper, lineWidth: 1.5))
                    Image(systemName: "arrow.right").font(.system(size: 17))
                    Text("よみび").font(.custom("HiraMinProN-W6", size: 26, relativeTo: .title2))
                }
                Text("アドレスバーの「ぁあ」から\n「よみび」を選ぶ")
                    .font(.custom("HiraMinProN-W3", size: 16, relativeTo: .body)).lineSpacing(7)
                Text("ここで初めて本文が整う")
                    .font(.system(size: 11)).foregroundStyle(Wafu07Palette.paper.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Wafu07Palette.paper)
            .background(Wafu07Palette.ink)
            .overlay(alignment: .trailing) {
                Rectangle().fill(Wafu07Palette.mist).frame(width: 4).padding(.vertical, 10).padding(.trailing, 6)
            }
            .padding(.top, 18)
        }
    }

    private var notice: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle").padding(.top, 2)
            VStack(alignment: .leading, spacing: 8) {
                Text("サイトごとに許可が要る")
                    .font(.custom("HiraMinProN-W6", size: 15, relativeTo: .headline))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12, weight: .regular)).lineSpacing(6)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu07Palette.mist.opacity(0.22))
        .overlay(alignment: .leading) { Rectangle().frame(width: 2) }
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack {
                Image(systemName: "safari").font(.system(size: 22))
                Spacer()
                Text("Safari を開く").font(.custom("HiraMinProN-W6", size: 18, relativeTo: .headline))
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .padding(.horizontal, 21).padding(.vertical, 20)
            .foregroundStyle(Wafu07Palette.paper)
            .background(Wafu07Palette.ink)
        }
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("文章に、静かな居場所を。")
                .font(.custom("HiraMinProN-W6", size: 18, relativeTo: .headline))
                .padding(.bottom, 3)
            Wafu07Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu07Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu07Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
    }

    private var footer: some View {
        VStack(spacing: 18) {
            Wafu07Seigaiha().frame(height: 26).clipped().opacity(0.4).accessibilityHidden(true)
            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(.system(size: 10)).multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }
}

private struct Wafu07Step: View {
    let number: String
    let title: String
    let detail: String?
    let note: String?

    var body: some View {
        HStack(alignment: .top, spacing: 17) {
            Text(number).font(.custom("HiraMinProN-W6", size: 25)).frame(width: 27)
            VStack(alignment: .leading, spacing: 9) {
                Text(title).font(.custom("HiraMinProN-W6", size: 16, relativeTo: .headline))
                if let detail { Text(detail).font(.system(size: 12)).lineSpacing(6) }
                if let note { Text(note).font(.system(size: 10)).foregroundStyle(Wafu07Palette.blue) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 20)
        .overlay(alignment: .bottom) { Rectangle().fill(Wafu07Palette.ink.opacity(0.25)).frame(height: 1) }
    }
}

private struct Wafu07Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 13) {
            Image(systemName: icon).frame(width: 19)
            Text(text).font(.system(size: 12, weight: .regular)).fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct Wafu07Mark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let ink = Wafu07Palette.ink
            context.stroke(Path(ellipseIn: CGRect(x: 2, y: 2, width: w - 4, height: h - 4)), with: .color(ink), lineWidth: 2.5)
            var book = Path()
            book.move(to: CGPoint(x: w * 0.23, y: h * 0.30))
            book.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.36), control: CGPoint(x: w * 0.39, y: h * 0.27))
            book.addQuadCurve(to: CGPoint(x: w * 0.77, y: h * 0.30), control: CGPoint(x: w * 0.61, y: h * 0.27))
            book.addLine(to: CGPoint(x: w * 0.77, y: h * 0.65))
            book.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.72), control: CGPoint(x: w * 0.62, y: h * 0.61))
            book.addQuadCurve(to: CGPoint(x: w * 0.23, y: h * 0.65), control: CGPoint(x: w * 0.38, y: h * 0.61))
            book.closeSubpath()
            book.move(to: CGPoint(x: w * 0.5, y: h * 0.36))
            book.addLine(to: CGPoint(x: w * 0.5, y: h * 0.72))
            context.stroke(book, with: .color(ink), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
        }
        .accessibilityHidden(true)
    }
}

private struct Wafu07Seigaiha: View {
    var body: some View {
        Canvas { context, size in
            for row in 0...Int(size.height / 22) + 1 {
                for column in -1...Int(size.width / 48) + 1 {
                    let center = CGPoint(x: CGFloat(column) * 48 + (row.isMultiple(of: 2) ? 0 : 24), y: CGFloat(row) * 22 + 24)
                    for radius in [8.0, 15.0, 22.0] {
                        var arc = Path()
                        arc.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        context.stroke(arc, with: .color(Wafu07Palette.blue), lineWidth: 1)
                    }
                }
            }
        }
    }
}

private struct Wafu07Wave: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: -10, y: 74))
        p.addCurve(to: CGPoint(x: 128, y: 44), control1: CGPoint(x: 49, y: 96), control2: CGPoint(x: 85, y: 87))
        p.addCurve(to: CGPoint(x: 227, y: 17), control1: CGPoint(x: 168, y: 3), control2: CGPoint(x: 205, y: -3))
        p.addCurve(to: CGPoint(x: 200, y: 41), control1: CGPoint(x: 248, y: 38), control2: CGPoint(x: 226, y: 55))
        p.addCurve(to: CGPoint(x: 203, y: 29), control1: CGPoint(x: 220, y: 42), control2: CGPoint(x: 217, y: 20))
        p.addCurve(to: CGPoint(x: 190, y: 57), control1: CGPoint(x: 190, y: 29), control2: CGPoint(x: 180, y: 44))
        p.addCurve(to: CGPoint(x: 293, y: 63), control1: CGPoint(x: 215, y: 86), control2: CGPoint(x: 260, y: 84))
        p.addCurve(to: CGPoint(x: 400, y: 55), control1: CGPoint(x: 334, y: 35), control2: CGPoint(x: 365, y: 39))
        p.addLine(to: CGPoint(x: 400, y: 104))
        p.addLine(to: CGPoint(x: -10, y: 104))
        p.closeSubpath()
        return p.applying(CGAffineTransform(scaleX: rect.width / 390, y: rect.height / 100).concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

private struct Wafu07WaveLines: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: -5, y: 87))
        p.addCurve(to: CGPoint(x: 164, y: 39), control1: CGPoint(x: 70, y: 118), control2: CGPoint(x: 123, y: 77))
        p.move(to: CGPoint(x: 38, y: 101))
        p.addCurve(to: CGPoint(x: 169, y: 55), control1: CGPoint(x: 92, y: 109), control2: CGPoint(x: 139, y: 88))
        p.move(to: CGPoint(x: 214, y: 90))
        p.addCurve(to: CGPoint(x: 399, y: 70), control1: CGPoint(x: 305, y: 115), control2: CGPoint(x: 314, y: 47))
        return p.applying(CGAffineTransform(scaleX: rect.width / 390, y: rect.height / 100).concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

#Preview { Wafu07Screen() }
