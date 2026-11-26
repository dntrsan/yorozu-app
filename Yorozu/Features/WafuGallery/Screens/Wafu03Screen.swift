import SwiftUI

// iOS 18 / Standalone screen. The state is a demonstration, not a Safari query.
struct Wafu03Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extState: ExtState = .on { didSet { WafuHaptics.tap() } }
    private var stateTitle: String {
        switch extState {
        case .on: "よみびはオンです"
        case .off: "よみびはオフです"
        case .checking: "拡張を確認中です"
        }
    }

    private var stateDetail: String {
        switch extState {
        case .on: "Safari で記事を開いてください"
        case .off: "下の手順で拡張をオンにしてください"
        case .checking: "拡張の状態を確認しています"
        }
    }

    private var stateIcon: String {
        switch extState {
        case .on: "checkmark.circle"
        case .off: "minus.circle"
        case .checking: "ellipsis.circle"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                masthead
                hero
                stateCard
                    .padding(.bottom, 32)
                guide
                permissionCard
                    .padding(.top, 20)
                safariLink
                    .padding(.top, 24)
                features
                    .padding(.top, 32)
                footer
            }
            .frame(maxWidth: 440)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu03Palette.black.ignoresSafeArea())
        .foregroundStyle(Wafu03Palette.ivory)
        .preferredColorScheme(.dark)
    }

    private var masthead: some View {
        HStack {
            Text("よみび / 読む支度")
                .tracking(2)
            Spacer()
            Text("漆と朱")
                .tracking(3)
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(Wafu03Palette.gold)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) { Wafu03Rule() }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Wafu03Mark()
                .frame(width: 76, height: 76)
                .padding(.top, 32)
                .padding(.bottom, 20)
            Text("よみび")
                .font(.custom("HiraMinProN-W3", size: 38, relativeTo: .largeTitle))
                .tracking(9)
                .padding(.leading, 9)
            Text("ウェブの文章を、本のように読む")
                .font(.custom("HiraMinProN-W3", size: 13, relativeTo: .subheadline))
                .tracking(0.8)
                .padding(.top, 12)
            HStack(spacing: 8) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.6)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .overlay { Rectangle().stroke(Wafu03Palette.rule, lineWidth: 0.5) }
                }
            }
            .foregroundStyle(Wafu03Palette.gold)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
    }

    private var stateCard: some View {
        Button(action: cycleState) {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: stateIcon)
                    .font(.system(size: 27, weight: .ultraLight))
                    .foregroundStyle(Wafu03Palette.gold)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 7) {
                    Text("拡張の状態")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(Wafu03Palette.gold)
                    Text(stateTitle)
                        .font(.custom("HiraMinProN-W6", size: 17, relativeTo: .headline))
                    Text(stateDetail)
                        .font(.system(size: 11))
                        .foregroundStyle(Wafu03Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Wafu03Palette.surface)
            .overlay { Rectangle().stroke(Wafu03Palette.rule, lineWidth: 0.5) }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("拡張の状態、\(stateTitle)。\(stateDetail)")
        .accessibilityHint("デザイン確認用。タップすると状態が切り替わります")
    }

    private var guide: some View {
        VStack(spacing: 14) {
            HStack {
                Text("設定の手順")
                    .font(.custom("HiraMinProN-W3", size: 18, relativeTo: .headline))
                    .tracking(3)
                Spacer()
                Text("全 四 段")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Wafu03Palette.gold)
            }
            VStack(spacing: 0) {
                Wafu03Step(number: "01", title: "機能拡張を開く",
                           detail: "設定アプリで「アプリ」→「Safari」\n→「機能拡張」を開く",
                           note: "設定アプリのいちばん下のほう")
                Wafu03Rule()
                Wafu03Step(number: "02", title: "「よみび」をオンにする",
                           detail: "拡張を使う準備をします")
                Wafu03Rule()
                Wafu03Step(number: "03", title: "好きな記事を開く",
                           detail: "Safari で、読みたいページへ")
                Wafu03Rule()
                Wafu03Step(number: "04", title: "「ぁあ」から「よみび」を選ぶ",
                           detail: "Safari のアドレスバーから",
                           note: "ここで初めて本文が整う", emphasized: true)
            }
            .background(Wafu03Palette.surface)
            .overlay { Rectangle().stroke(Wafu03Palette.rule, lineWidth: 0.5) }
        }
    }

    private var permissionCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(Wafu03Palette.gold)
            VStack(alignment: .leading, spacing: 7) {
                Text("サイトごとに許可が要る")
                    .font(.system(size: 12, weight: .medium))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 11))
                    .foregroundStyle(Wafu03Palette.muted)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay { Rectangle().stroke(Wafu03Palette.rule, lineWidth: 0.5) }
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack {
                Image(systemName: "safari")
                    .font(.system(size: 22, weight: .light))
                Spacer()
                Text("Safari を開く")
                    .font(.custom("HiraMinProN-W6", size: 17, relativeTo: .headline))
                    .tracking(2)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .light))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 19)
            .foregroundStyle(Wafu03Palette.ivory)
            .background(Wafu03Palette.red)
            .overlay { Rectangle().stroke(Wafu03Palette.gold.opacity(0.6), lineWidth: 0.5) }
        }
        .buttonStyle(.plain)
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 17) {
            Text("ひとつの記事を、ゆっくりと。")
                .font(.custom("HiraMinProN-W3", size: 13, relativeTo: .subheadline))
                .tracking(1)
                .padding(.bottom, 3)
            Wafu03Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu03Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu03Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 19) {
            Wafu03Rule()
            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(.system(size: 10))
                .foregroundStyle(Wafu03Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 30)
    }

    private func cycleState() {
        switch extState {
        case .on: extState = .off
        case .off: extState = .checking
        case .checking: extState = .on
        }
    }
}

private enum Wafu03Palette {
    static let black = Color(red: 18 / 255.0, green: 17 / 255.0, blue: 16 / 255.0)
    static let surface = Color(red: 28 / 255.0, green: 24 / 255.0, blue: 22 / 255.0)
    static let red = Color(red: 154 / 255.0, green: 48 / 255.0, blue: 37 / 255.0)
    static let gold = Color(red: 202 / 255.0, green: 170 / 255.0, blue: 111 / 255.0)
    static let rule = Color(red: 113 / 255.0, green: 91 / 255.0, blue: 61 / 255.0)
    static let ivory = Color(red: 245 / 255.0, green: 236 / 255.0, blue: 218 / 255.0)
    static let muted = Color(red: 182 / 255.0, green: 169 / 255.0, blue: 151 / 255.0)
}

private struct Wafu03Rule: View {
    var body: some View { Rectangle().fill(Wafu03Palette.rule).frame(height: 0.5) }
}

private struct Wafu03Step: View {
    let number: String
    let title: String
    let detail: String
    var note: String? = nil
    var emphasized = false

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.custom("HiraMinProN-W3", size: 21, relativeTo: .title3))
                .foregroundStyle(Wafu03Palette.gold)
                .frame(width: 29, alignment: .leading)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 9) {
                Text(title)
                    .font(.custom("HiraMinProN-W6", size: 15, relativeTo: .headline))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(emphasized ? Wafu03Palette.ivory : Wafu03Palette.muted)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                if let note {
                    Text(note)
                        .font(.system(size: 10, weight: emphasized ? .medium : .regular))
                        .foregroundStyle(emphasized ? Wafu03Palette.ivory : Wafu03Palette.gold)
                        .padding(.top, emphasized ? 4 : 0)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(emphasized ? Wafu03Palette.red : Wafu03Palette.surface)
    }
}

private struct Wafu03Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Wafu03Palette.gold)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 11))
                .foregroundStyle(Wafu03Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct Wafu03Mark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Wafu03Palette.red)
            RoundedRectangle(cornerRadius: 7)
                .inset(by: 5)
                .stroke(Wafu03Palette.gold, lineWidth: 0.6)
            Wafu03BookShape()
                .stroke(Wafu03Palette.gold, style: StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round))
                .padding(6)
        }
        .accessibilityHidden(true)
    }
}

private struct Wafu03BookShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 64
        let sy = rect.height / 64
        var path = Path()
        path.move(to: CGPoint(x: 12, y: 23))
        path.addQuadCurve(to: CGPoint(x: 32, y: 28), control: CGPoint(x: 23, y: 21))
        path.addQuadCurve(to: CGPoint(x: 52, y: 23), control: CGPoint(x: 41, y: 21))
        path.addLine(to: CGPoint(x: 52, y: 47))
        path.addQuadCurve(to: CGPoint(x: 32, y: 52), control: CGPoint(x: 41, y: 45))
        path.addQuadCurve(to: CGPoint(x: 12, y: 47), control: CGPoint(x: 23, y: 45))
        path.closeSubpath()
        path.move(to: CGPoint(x: 32, y: 28))
        path.addLine(to: CGPoint(x: 32, y: 52))
        for y in [31.0, 37.0] {
            path.move(to: CGPoint(x: 18, y: y))
            path.addLine(to: CGPoint(x: 26, y: y + 2))
            path.move(to: CGPoint(x: 38, y: y + 2))
            path.addLine(to: CGPoint(x: 46, y: y))
        }
        path.move(to: CGPoint(x: 32, y: 9))
        path.addQuadCurve(to: CGPoint(x: 32, y: 21), control: CGPoint(x: 21, y: 19))
        path.addQuadCurve(to: CGPoint(x: 32, y: 9), control: CGPoint(x: 42, y: 21))
        return path.applying(CGAffineTransform(scaleX: sx, y: sy))
    }
}

#Preview { Wafu03Screen() }
