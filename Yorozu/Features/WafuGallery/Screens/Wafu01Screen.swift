import SwiftUI

struct Wafu01Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extensionState: ExtState = .on { didSet { WafuHaptics.tap() } }
    private var stateTitle: String {
        switch extensionState {
        case .on: return "拡張はオンです"
        case .off: return "拡張はオフです"
        case .checking: return "拡張を確認中です"
        }
    }

    private var stateDetail: String {
        switch extensionState {
        case .on: return "読む準備ができています"
        case .off: return "手順に沿ってオンにしてください"
        case .checking: return "設定の状態を確認しています"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                status.padding(.top, 38)
                guide.padding(.top, 48)
                permission.padding(.top, 28)
                safariLink.padding(.top, 24)
                benefits.padding(.top, 38)
                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(.system(size: 10))
                    .foregroundStyle(Wafu01Palette.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 28)
            .padding(.top, 40)
            .padding(.bottom, 32)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu01Paper().ignoresSafeArea())
        .foregroundStyle(Wafu01Palette.ink)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("読む時間に、余白を。")
                .font(Wafu01Palette.mincho(12))
                .tracking(2.4)
                .foregroundStyle(Wafu01Palette.secondary)
            HStack(alignment: .center) {
                Text("よみび")
                    .font(Wafu01Palette.mincho(50))
                    .tracking(7)
                Spacer(minLength: 12)
                Wafu01BookMark().frame(width: 48, height: 52)
                    .accessibilityHidden(true)
            }
            .padding(.top, 30)
            Wafu01Brush().fill(Wafu01Palette.ink)
                .frame(width: 214, height: 18)
                .padding(.top, 14)
                .accessibilityHidden(true)
            Text("ウェブの文章を、本のように読む")
                .font(Wafu01Palette.mincho(15))
                .lineSpacing(7)
                .padding(.top, 27)
            HStack(spacing: 8) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .overlay(Rectangle().stroke(Wafu01Palette.rule, lineWidth: 0.7))
                }
            }
            .foregroundStyle(Wafu01Palette.secondary)
            .padding(.top, 21)
        }
    }

    private var status: some View {
        Button {
            switch extensionState {
            case .on: extensionState = .off
            case .off: extensionState = .checking
            case .checking: extensionState = .on
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: extensionState == .on ? "checkmark.circle" : extensionState == .off ? "minus.circle" : "ellipsis.circle")
                    .font(.system(size: 24, weight: .ultraLight))
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 7) {
                    Text(stateTitle).font(Wafu01Palette.mincho(17))
                    Text(stateDetail).font(.system(size: 11))
                        .foregroundStyle(Wafu01Palette.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Rectangle().stroke(Wafu01Palette.rule, lineWidth: 0.8))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("デザイン確認用。タップすると表示状態が切り替わります")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("はじめの、四つ。")
                    .font(Wafu01Palette.mincho(23))
                Spacer()
                Text("設定ガイド").font(.system(size: 10)).tracking(1)
                    .foregroundStyle(Wafu01Palette.secondary)
            }
            .padding(.bottom, 14)
            Wafu01Step(number: "一", title: "設定から、機能拡張へ", detail: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
            Wafu01Step(number: "二", title: "「よみび」をオンにする")
            Wafu01Step(number: "三", title: "Safari で好きな記事を開く")
            Wafu01Step(number: "四", title: "「ぁあ」から、よみびへ", detail: "アドレスバーの「ぁあ」から「よみび」を選ぶ", note: "ここで初めて本文が整う", highlighted: true)
        }
    }

    private var permission: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle").font(.system(size: 15))
                .padding(.top, 2).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text("サイトごとに許可が要る").font(Wafu01Palette.mincho(14))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12)).lineSpacing(6)
                    .foregroundStyle(Wafu01Palette.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu01Palette.wash)
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack {
                Spacer()
                Text("Safari を開く").font(Wafu01Palette.mincho(16))
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 14))
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 58)
            .background(Wafu01Palette.ink)
            .foregroundStyle(Wafu01Palette.paper)
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 18) {
            Wafu01Benefit(symbol: "doc.plaintext", text: "本文だけを抜き出して明朝体で組む")
            Wafu01Benefit(symbol: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu01Benefit(symbol: "bookmark", text: "読んだ位置を覚えておく")
        }
    }
}

private enum Wafu01Palette {
    static let paper = Color(red: 0.965, green: 0.949, blue: 0.906)
    static let ink = Color(red: 0.161, green: 0.157, blue: 0.141)
    static let secondary = Color(red: 0.416, green: 0.400, blue: 0.365)
    static let rule = Color(red: 0.776, green: 0.753, blue: 0.690)
    static let wash = Color(red: 0.925, green: 0.906, blue: 0.863)
    static func mincho(_ size: CGFloat) -> Font { .custom("HiraMinProN-W3", size: size) }
}

private struct Wafu01Step: View {
    let number: String
    let title: String
    var detail: String? = nil
    var note: String? = nil
    var highlighted = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(number).font(Wafu01Palette.mincho(19))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 10) {
                if highlighted {
                    Text("本文を整える").font(.system(size: 10)).tracking(2)
                }
                Text(title).font(Wafu01Palette.mincho(16)).lineSpacing(5)
                if let detail {
                    Text(detail).font(.system(size: 12)).lineSpacing(7)
                        .foregroundStyle(highlighted ? Wafu01Palette.paper : Wafu01Palette.secondary)
                }
                if let note {
                    Text(note).font(.system(size: 10)).lineSpacing(4)
                        .foregroundStyle(highlighted ? Wafu01Palette.paper : Wafu01Palette.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, highlighted ? 24 : 22)
        .padding(.horizontal, highlighted ? 18 : 0)
        .foregroundStyle(highlighted ? Wafu01Palette.paper : Wafu01Palette.ink)
        .background(highlighted ? Wafu01Palette.ink : Color.clear)
        .overlay(alignment: .bottom) {
            if !highlighted { Rectangle().fill(Wafu01Palette.rule).frame(height: 0.5) }
        }
        .padding(.top, highlighted ? 16 : 0)
    }
}

private struct Wafu01Benefit: View {
    let symbol: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).font(.system(size: 15, weight: .light))
                .frame(width: 20).accessibilityHidden(true)
            Text(text).font(.system(size: 11)).lineSpacing(5)
        }
        .foregroundStyle(Wafu01Palette.secondary)
    }
}

private struct Wafu01BookMark: View {
    var body: some View {
        Canvas { context, size in
            var book = Path()
            book.move(to: CGPoint(x: 3, y: 8))
            book.addQuadCurve(to: CGPoint(x: 24, y: 14), control: CGPoint(x: 16, y: 7))
            book.addQuadCurve(to: CGPoint(x: 45, y: 8), control: CGPoint(x: 34, y: 7))
            book.addLine(to: CGPoint(x: 45, y: 42))
            book.addQuadCurve(to: CGPoint(x: 24, y: 48), control: CGPoint(x: 33, y: 41))
            book.addQuadCurve(to: CGPoint(x: 3, y: 42), control: CGPoint(x: 15, y: 41))
            book.closeSubpath()
            book.move(to: CGPoint(x: 24, y: 14))
            book.addLine(to: CGPoint(x: 24, y: 48))
            context.stroke(book, with: .color(Wafu01Palette.ink), lineWidth: 1.2)
            context.fill(Path(CGRect(x: 32, y: 0, width: 3, height: 22)), with: .color(Wafu01Palette.ink))
        }
    }
}

private struct Wafu01Brush: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height * 0.54))
        p.addCurve(to: CGPoint(x: rect.width, y: 0), control1: CGPoint(x: rect.width * 0.25, y: rect.height * 0.78), control2: CGPoint(x: rect.width * 0.75, y: rect.height * 0.8))
        p.addCurve(to: CGPoint(x: rect.width * 0.08, y: rect.height * 0.9), control1: CGPoint(x: rect.width * 0.72, y: rect.height * 1.08), control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.95))
        p.closeSubpath()
        return p
    }
}

private struct Wafu01Paper: View {
    var body: some View {
        Wafu01Palette.paper.overlay {
            Canvas { context, size in
                for i in 0..<1800 {
                    let x = CGFloat((i * 73 + 19) % 997) / 997 * size.width
                    let y = CGFloat((i * 137 + 43) % 991) / 991 * size.height
                    let fiber = CGRect(x: x, y: y, width: i % 3 == 0 ? 2 : 0.6, height: 0.5)
                    context.fill(Path(fiber), with: .color(Wafu01Palette.ink.opacity(0.055)))
                }
            }
            .accessibilityHidden(true)
            .allowsHitTesting(false)
        }
    }
}

#Preview { Wafu01Screen() }
