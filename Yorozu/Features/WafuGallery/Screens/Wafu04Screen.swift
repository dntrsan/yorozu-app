import SwiftUI

// iOS 18 / Standalone screen. State cycling is for design inspection only.
struct Wafu04Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extState: ExtState = .on

    private var stateTitle: String {
        switch extState {
        case .on: "よみびはオンです"
        case .off: "よみびはオフです"
        case .checking: "拡張を確認中です"
        }
    }

    private var stateDetail: String {
        switch extState {
        case .on: "記事を開いたら、手順4へ。"
        case .off: "下の手順で、拡張をオンに。"
        case .checking: "拡張の状態を確認しています。"
        }
    }

    private var stateIcon: String {
        switch extState {
        case .on: "checkmark"
        case .off: "minus"
        case .checking: "ellipsis"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                VStack(spacing: 0) {
                    stateCard
                        .padding(.bottom, 34)
                    guide
                    permissionCard
                        .padding(.top, 22)
                    safariLink
                        .padding(.top, 24)
                    features
                        .padding(.top, 34)
                    footer
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: 488)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu04Palette.paper.ignoresSafeArea())
        .foregroundStyle(Wafu04Palette.ink)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("読む、春の支度。")
                    .tracking(2)
                Spacer()
                Text("桜と春霞")
                    .tracking(2)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Wafu04Palette.rose)
            .padding(.top, 28)
            HStack(alignment: .center) {
                Text("よみび")
                    .font(.custom("HiraMinProN-W3", size: 42, relativeTo: .largeTitle))
                    .tracking(6)
                Spacer(minLength: 12)
                Wafu04Mark()
                    .frame(width: 68, height: 68)
            }
            .padding(.top, 39)
            Text("ウェブの文章を、\n本のように読む")
                .font(.custom("HiraMinProN-W3", size: 17, relativeTo: .headline))
                .tracking(1.5)
                .lineSpacing(8)
                .padding(.top, 13)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.4)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.7), in: Capsule())
                }
            }
            .foregroundStyle(Wafu04Palette.rose)
            .padding(.top, 21)
            .padding(.bottom, 31)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { Wafu04Mist().allowsHitTesting(false) }
    }

    private var stateCard: some View {
        Button(action: cycleState) {
            HStack(spacing: 13) {
                Image(systemName: stateIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Wafu04Palette.sage)
                    .frame(width: 36, height: 36)
                    .background(Wafu04Palette.sageWash, in: Circle())
                VStack(alignment: .leading, spacing: 6) {
                    Text("拡張の状態")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundStyle(Wafu04Palette.muted)
                    Text(stateTitle)
                        .font(.custom("HiraMinProN-W6", size: 16, relativeTo: .headline))
                    Text(stateDetail)
                        .font(.system(size: 11))
                        .foregroundStyle(Wafu04Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
            .overlay { RoundedRectangle(cornerRadius: 16).stroke(Wafu04Palette.line, lineWidth: 0.7) }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("拡張の状態、\(stateTitle)。\(stateDetail)")
        .accessibilityHint("デザイン確認用。タップすると状態が切り替わります")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("読みはじめるまで")
                    .font(.custom("HiraMinProN-W3", size: 20, relativeTo: .title2))
                    .tracking(1)
                Spacer(minLength: 8)
                Text("4つの手順")
                    .font(.system(size: 10))
                    .foregroundStyle(Wafu04Palette.muted)
            }
            .padding(.bottom, 25)
            Wafu04TimelineStep(number: "1", title: "機能拡張を開く",
                               detail: "設定アプリで「アプリ」→「Safari」\n→「機能拡張」を開く",
                               note: "設定アプリのいちばん下のほう")
            Wafu04TimelineStep(number: "2", title: "「よみび」をオンにする",
                               detail: "拡張を使う準備をします")
            Wafu04TimelineStep(number: "3", title: "Safari で好きな記事を開く",
                               detail: "いつものウェブが、読書の入口に。", last: true)
            finalStep
                .padding(.top, 3)
        }
    }

    private var finalStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("4")
                    .font(.custom("HiraMinProN-W3", size: 16, relativeTo: .body))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Wafu04Palette.rose, in: Circle())
                Text("最後に、記事のページで")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Wafu04Palette.rose)
            }
            Text("「ぁあ」から「よみび」を選ぶ")
                .font(.custom("HiraMinProN-W6", size: 16, relativeTo: .headline))
                .lineSpacing(5)
                .padding(.top, 14)
                .fixedSize(horizontal: false, vertical: true)
            Text("Safari のアドレスバーから")
                .font(.system(size: 11))
                .foregroundStyle(Wafu04Palette.muted)
                .padding(.top, 8)
            HStack(spacing: 12) {
                Text("ぁあ")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 38)
                Rectangle().fill(Wafu04Palette.line).frame(width: 1, height: 21)
                Text("よみび")
                    .font(.custom("HiraMinProN-W3", size: 14, relativeTo: .body))
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Wafu04Palette.rose)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 10))
            .padding(.top, 17)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("操作のイメージ：ぁあのメニューからよみびを選択")
            Text("ここで初めて本文が整う")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Wafu04Palette.rose)
                .padding(.top, 13)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu04Palette.blush, in: RoundedRectangle(cornerRadius: 20))
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(Wafu04Palette.line, lineWidth: 0.7) }
    }

    private var permissionCard: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Wafu04Palette.rose)
            VStack(alignment: .leading, spacing: 7) {
                Text("サイトごとに許可が要る")
                    .font(.system(size: 12, weight: .medium))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 11))
                    .foregroundStyle(Wafu04Palette.muted)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu04Palette.linen, in: RoundedRectangle(cornerRadius: 12))
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack(spacing: 12) {
                Image(systemName: "safari")
                    .font(.system(size: 21, weight: .light))
                Text("Safari を開く")
                    .font(.custom("HiraMinProN-W6", size: 17, relativeTo: .headline))
                    .tracking(1)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.leading, 8)
            }
            .padding(.vertical, 19)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(Wafu04Palette.rose, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("読む時間に、やさしい余白を。")
                .font(.custom("HiraMinProN-W3", size: 15, relativeTo: .subheadline))
                .tracking(0.5)
                .padding(.bottom, 4)
            Wafu04Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu04Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu04Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            Rectangle().fill(Wafu04Palette.line).frame(height: 0.7)
            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(.system(size: 10))
                .foregroundStyle(Wafu04Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 31)
    }

    private func cycleState() {
        switch extState {
        case .on: extState = .off
        case .off: extState = .checking
        case .checking: extState = .on
        }
    }
}

private enum Wafu04Palette {
    static let paper = Color(red: 252 / 255.0, green: 249 / 255.0, blue: 247 / 255.0)
    static let blush = Color(red: 247 / 255.0, green: 231 / 255.0, blue: 232 / 255.0)
    static let pink = Color(red: 242 / 255.0, green: 212 / 255.0, blue: 219 / 255.0)
    static let rose = Color(red: 156 / 255.0, green: 82 / 255.0, blue: 103 / 255.0)
    static let ink = Color(red: 77 / 255.0, green: 57 / 255.0, blue: 66 / 255.0)
    static let muted = Color(red: 122 / 255.0, green: 104 / 255.0, blue: 111 / 255.0)
    static let line = Color(red: 231 / 255.0, green: 212 / 255.0, blue: 216 / 255.0)
    static let linen = Color(red: 243 / 255.0, green: 238 / 255.0, blue: 232 / 255.0)
    static let sage = Color(red: 85 / 255.0, green: 114 / 255.0, blue: 97 / 255.0)
    static let sageWash = Color(red: 237 / 255.0, green: 243 / 255.0, blue: 237 / 255.0)
}

private struct Wafu04TimelineStep: View {
    let number: String
    let title: String
    let detail: String
    var note: String? = nil
    var last = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(number)
                .font(.custom("HiraMinProN-W3", size: 16, relativeTo: .body))
                .foregroundStyle(Wafu04Palette.rose)
                .frame(width: 28, height: 28)
                .background(Wafu04Palette.blush, in: Circle())
            VStack(alignment: .leading, spacing: 9) {
                Text(title)
                    .font(.custom("HiraMinProN-W6", size: 15, relativeTo: .headline))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Wafu04Palette.muted)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                if let note {
                    Text(note)
                        .font(.system(size: 10))
                        .foregroundStyle(Wafu04Palette.rose)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 2)
            Spacer(minLength: 0)
        }
        .padding(.bottom, last ? 23 : 29)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .topLeading) {
            if !last {
                Rectangle()
                    .fill(Wafu04Palette.line)
                    .frame(width: 0.7)
                    .padding(.top, 32)
                    .padding(.bottom, 4)
                    .padding(.leading, 14)
            }
        }
    }
}

private struct Wafu04Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Wafu04Palette.rose)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 11))
                .foregroundStyle(Wafu04Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct Wafu04Mist: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [Wafu04Palette.blush, Wafu04Palette.paper], startPoint: .top, endPoint: .bottom)
                Ellipse()
                    .fill(Wafu04Palette.pink.opacity(0.4))
                    .frame(width: w * 0.8, height: h * 0.56)
                    .blur(radius: 28)
                    .offset(x: w * 0.4, y: h * 0.12)
                Wafu04MistBand()
                    .fill(.white.opacity(0.5))
                    .frame(width: w, height: h)
                Wafu04Petal()
                    .fill(Wafu04Palette.pink.opacity(0.8))
                    .frame(width: 11, height: 20)
                    .rotationEffect(.degrees(28))
                    .position(x: w * 0.57, y: h * 0.22)
                Wafu04Petal()
                    .fill(Wafu04Palette.pink.opacity(0.65))
                    .frame(width: 8, height: 15)
                    .rotationEffect(.degrees(-24))
                    .position(x: w * 0.91, y: h * 0.62)
                Wafu04Petal()
                    .fill(Wafu04Palette.pink.opacity(0.6))
                    .frame(width: 7, height: 12)
                    .rotationEffect(.degrees(58))
                    .position(x: w * 0.68, y: h * 0.79)
            }
            .clipped()
        }
        .accessibilityHidden(true)
    }
}

private struct Wafu04MistBand: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height * 0.45))
        p.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.28),
                   control1: CGPoint(x: rect.width * 0.34, y: rect.height * 0.12),
                   control2: CGPoint(x: rect.width * 0.64, y: rect.height * 0.57))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.42))
        p.addCurve(to: CGPoint(x: 0, y: rect.height * 0.66),
                   control1: CGPoint(x: rect.width * 0.64, y: rect.height * 0.73),
                   control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.37))
        p.closeSubpath()
        return p
    }
}

private struct Wafu04Petal: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addCurve(to: CGPoint(x: rect.width * 0.2, y: 0),
                   control1: CGPoint(x: -rect.width * 0.25, y: rect.height * 0.58),
                   control2: CGPoint(x: 0, y: rect.height * 0.13))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.height * 0.16))
        p.addLine(to: CGPoint(x: rect.width * 0.8, y: 0))
        p.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                   control1: CGPoint(x: rect.width, y: rect.height * 0.13),
                   control2: CGPoint(x: rect.width * 1.25, y: rect.height * 0.58))
        p.closeSubpath()
        return p
    }
}

private struct Wafu04Mark: View {
    var body: some View {
        ZStack {
            Circle().fill(.white.opacity(0.68))
            Circle().stroke(Wafu04Palette.line, lineWidth: 0.7)
            Wafu04BookShape()
                .stroke(Wafu04Palette.rose, style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
                .padding(7)
        }
        .accessibilityHidden(true)
    }
}

private struct Wafu04BookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 10, y: 22))
        p.addQuadCurve(to: CGPoint(x: 27, y: 26), control: CGPoint(x: 20, y: 20))
        p.addQuadCurve(to: CGPoint(x: 44, y: 22), control: CGPoint(x: 34, y: 20))
        p.addLine(to: CGPoint(x: 44, y: 42))
        p.addQuadCurve(to: CGPoint(x: 27, y: 46), control: CGPoint(x: 34, y: 40))
        p.addQuadCurve(to: CGPoint(x: 10, y: 42), control: CGPoint(x: 20, y: 40))
        p.closeSubpath()
        p.move(to: CGPoint(x: 27, y: 26))
        p.addLine(to: CGPoint(x: 27, y: 46))
        p.move(to: CGPoint(x: 16, y: 29))
        p.addLine(to: CGPoint(x: 22, y: 31))
        p.move(to: CGPoint(x: 32, y: 31))
        p.addLine(to: CGPoint(x: 38, y: 29))
        p.move(to: CGPoint(x: 27, y: 8))
        p.addQuadCurve(to: CGPoint(x: 27, y: 19), control: CGPoint(x: 17, y: 17))
        p.addQuadCurve(to: CGPoint(x: 27, y: 8), control: CGPoint(x: 36, y: 19))
        return p.applying(CGAffineTransform(scaleX: rect.width / 54, y: rect.height / 54))
    }
}

#Preview { Wafu04Screen() }
