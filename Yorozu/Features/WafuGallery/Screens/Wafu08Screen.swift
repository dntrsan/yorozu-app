import SwiftUI

private enum Wafu08Palette {
    static let ink = Color(red: 23.0 / 255, green: 23.0 / 255, blue: 20.0 / 255)
    static let gold = Color(red: 199.0 / 255, green: 163.0 / 255, blue: 89.0 / 255)
    static let lightGold = Color(red: 230.0 / 255, green: 201.0 / 255, blue: 133.0 / 255)
    static let deepGold = Color(red: 148.0 / 255, green: 112.0 / 255, blue: 51.0 / 255)
    static let ivory = Color(red: 247.0 / 255, green: 240.0 / 255, blue: 219.0 / 255)
    static let muted = Color(red: 186.0 / 255, green: 179.0 / 255, blue: 158.0 / 255)
    static let red = Color(red: 179.0 / 255, green: 51.0 / 255, blue: 36.0 / 255)
}

struct Wafu08Screen: View {
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
        case .off: return "手順02でオンにしてください"
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
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu08Palette.ink)
        .foregroundStyle(Wafu08Palette.ivory)
        .preferredColorScheme(.dark)
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack {
                Text("YOMIBI")
                Spacer()
                Text("はじめての方へ")
            }
            .font(.system(size: 10, weight: .medium))
            .tracking(2.5)
            .padding(.horizontal, 24)
            .padding(.vertical, 19)

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 14) {
                    Wafu08Mark().frame(width: 51, height: 51)
                    Text("よ\nみ\nび")
                        .font(.custom("HiraMinProN-W6", size: 45, relativeTo: .largeTitle))
                        .lineSpacing(0)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 10) {
                    VStack(spacing: 0) {
                        ForEach(Array("文章に、ひと息。").enumerated(), id: \.offset) { _, character in
                            Text(String(character))
                                .font(.custom("HiraMinProN-W3", size: 22, relativeTo: .title2))
                                .frame(minHeight: 28.6)
                                .offset(x: character == "、" || character == "。" ? 7 : 0,
                                        y: character == "、" || character == "。" ? -7 : 0)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("文章に、ひと息。")
                    Text("読書")
                        .font(.custom("HiraMinProN-W6", size: 11))
                        .foregroundStyle(Wafu08Palette.ivory)
                        .padding(.horizontal, 7).padding(.vertical, 5)
                        .background(Wafu08Palette.red)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 14)
            .padding(.horizontal, 55)

            Text("ウェブの文章を、本のように読む")
                .font(.custom("HiraMinProN-W3", size: 14, relativeTo: .body))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            HStack(spacing: 0) {
                Text("v1.0")
                Text("／").padding(.horizontal, 12)
                Text("iOS 18+")
                Text("／").padding(.horizontal, 12)
                Text("Safari")
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .padding(.top, 16)
            .padding(.bottom, 29)
        }
        .foregroundStyle(Wafu08Palette.ink)
        .background { Wafu08GoldGround() }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Wafu08Palette.deepGold).frame(height: 5)
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
                ZStack {
                    Circle().stroke(Wafu08Palette.gold, lineWidth: 1).frame(width: 31, height: 31)
                    Image(systemName: state == .on ? "checkmark" : state == .off ? "minus" : "ellipsis")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Wafu08Palette.lightGold)
                }
                VStack(alignment: .leading, spacing: 7) {
                    Text(stateTitle).font(.custom("HiraMinProN-W6", size: 18, relativeTo: .headline))
                    Text(stateDetail).font(.system(size: 10)).foregroundStyle(Wafu08Palette.muted)
                }
                Spacer(minLength: 0)
                Text(state == .on ? "ON" : state == .off ? "OFF" : "…")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(Wafu08Palette.lightGold)
            }
            .padding(.vertical, 21)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(Rectangle().stroke(Wafu08Palette.gold.opacity(0.6), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(stateTitle)。\(stateDetail)")
        .accessibilityHint("タップで表示サンプルの状態を切り替えます")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("お読みになる前に")
                .font(.custom("HiraMinProN-W3", size: 25, relativeTo: .title2))
                .tracking(1)
            HStack(spacing: 12) {
                Rectangle().fill(Wafu08Palette.gold).frame(width: 23, height: 1)
                Text("四つの支度").font(.system(size: 10)).tracking(2)
            }
            .foregroundStyle(Wafu08Palette.lightGold)
            .padding(.top, 12)
            .padding(.bottom, 9)

            Wafu08Step(number: "01", title: "設定の扉を開く", detail: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
            Wafu08Step(number: "02", title: "「よみび」をオンにする", detail: nil, note: nil)
            Wafu08Step(number: "03", title: "Safari で好きな記事を開く", detail: nil, note: nil)

            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .firstTextBaseline) {
                    Text("04").font(.system(size: 13, weight: .medium, design: .monospaced))
                    Spacer()
                    Text("最後に、このひと手間")
                        .font(.system(size: 10, weight: .medium)).tracking(1)
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("ぁあ")
                        .font(.custom("HiraMinProN-W6", size: 25))
                        .padding(.horizontal, 13).padding(.vertical, 8)
                        .overlay(Rectangle().stroke(Wafu08Palette.ink.opacity(0.5)))
                    Image(systemName: "arrow.right").font(.system(size: 17))
                    Text("よみび").font(.custom("HiraMinProN-W6", size: 27, relativeTo: .title2))
                }
                Text("アドレスバーの「ぁあ」から\n「よみび」を選ぶ")
                    .font(.custom("HiraMinProN-W6", size: 16, relativeTo: .body))
                    .lineSpacing(7)
                HStack(spacing: 7) {
                    Rectangle().fill(Wafu08Palette.red).frame(width: 5, height: 5)
                    Text("ここで初めて本文が整う").font(.system(size: 11))
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Wafu08Palette.ink)
            .background { Wafu08GoldGround(folded: false) }
            .overlay(alignment: .topLeading) {
                Rectangle().fill(Wafu08Palette.red).frame(width: 36, height: 3)
            }
            .padding(.top, 22)
        }
    }

    private var notice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .foregroundStyle(Wafu08Palette.lightGold).padding(.top, 2)
            VStack(alignment: .leading, spacing: 9) {
                Text("サイトごとに許可が要る")
                    .font(.custom("HiraMinProN-W6", size: 15, relativeTo: .headline))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12)).lineSpacing(6)
                    .foregroundStyle(Wafu08Palette.muted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu08Palette.ivory.opacity(0.04))
        .overlay(Rectangle().stroke(Wafu08Palette.gold.opacity(0.2)))
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack {
                Image(systemName: "safari").font(.system(size: 22))
                Spacer()
                Text("Safari を開く")
                    .font(.custom("HiraMinProN-W6", size: 18, relativeTo: .headline))
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .padding(.horizontal, 22).padding(.vertical, 21)
            .foregroundStyle(Wafu08Palette.ivory)
            .background(Wafu08Palette.red)
        }
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 19) {
            Text("読む時間を、しつらえる。")
                .font(.custom("HiraMinProN-W3", size: 18, relativeTo: .headline))
                .padding(.bottom, 4)
            Wafu08Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu08Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu08Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
        .padding(.top, 3)
    }

    private var footer: some View {
        VStack(spacing: 21) {
            HStack(spacing: 10) {
                Rectangle().fill(Wafu08Palette.gold.opacity(0.35)).frame(height: 1)
                Rectangle().fill(Wafu08Palette.gold).frame(width: 5, height: 5).rotationEffect(.degrees(45))
                Rectangle().fill(Wafu08Palette.gold.opacity(0.35)).frame(height: 1)
            }
            .accessibilityHidden(true)
            Text("よみび 1.0 ・ 設定はいつでも変えられます")
                .font(.system(size: 10)).foregroundStyle(Wafu08Palette.muted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 3)
    }
}

private struct Wafu08Step: View {
    let number: String
    let title: String
    let detail: String?
    let note: String?
    var body: some View {
        HStack(alignment: .top, spacing: 17) {
            Text(number)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Wafu08Palette.lightGold)
                .padding(.top, 5)
                .frame(width: 25)
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.custom("HiraMinProN-W3", size: 16, relativeTo: .headline))
                if let detail {
                    Text(detail).font(.system(size: 12)).lineSpacing(6)
                        .foregroundStyle(Wafu08Palette.muted)
                }
                if let note {
                    Text(note).font(.system(size: 10)).foregroundStyle(Wafu08Palette.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 23)
        .overlay(alignment: .bottom) { Rectangle().fill(Wafu08Palette.gold.opacity(0.22)).frame(height: 1) }
    }
}

private struct Wafu08Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 13) {
            Image(systemName: icon).foregroundStyle(Wafu08Palette.lightGold).frame(width: 19)
            Text(text).font(.system(size: 12)).foregroundStyle(Wafu08Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct Wafu08Mark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var screen = Path()
            screen.move(to: CGPoint(x: w * 0.10, y: h * 0.22))
            screen.addLine(to: CGPoint(x: w * 0.36, y: h * 0.13))
            screen.addLine(to: CGPoint(x: w * 0.64, y: h * 0.22))
            screen.addLine(to: CGPoint(x: w * 0.90, y: h * 0.13))
            screen.addLine(to: CGPoint(x: w * 0.90, y: h * 0.78))
            screen.addLine(to: CGPoint(x: w * 0.64, y: h * 0.87))
            screen.addLine(to: CGPoint(x: w * 0.36, y: h * 0.78))
            screen.addLine(to: CGPoint(x: w * 0.10, y: h * 0.87))
            screen.closeSubpath()
            screen.move(to: CGPoint(x: w * 0.36, y: h * 0.13))
            screen.addLine(to: CGPoint(x: w * 0.36, y: h * 0.78))
            screen.move(to: CGPoint(x: w * 0.64, y: h * 0.22))
            screen.addLine(to: CGPoint(x: w * 0.64, y: h * 0.87))
            context.stroke(screen, with: .color(Wafu08Palette.ink), style: StrokeStyle(lineWidth: 2, lineJoin: .miter))
        }
        .accessibilityHidden(true)
    }
}

private struct Wafu08GoldGround: View {
    var folded = true

    var body: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            context.fill(Path(bounds), with: .color(Wafu08Palette.gold))
            let tile: CGFloat = 49
            for row in 0...Int(size.height / tile) {
                for column in 0...Int(size.width / tile) {
                    let rect = CGRect(x: CGFloat(column) * tile, y: CGFloat(row) * tile, width: tile, height: tile)
                    let value = (row * 7 + column * 3) % 5
                    let tint = value.isMultiple(of: 2) ? Wafu08Palette.lightGold : Wafu08Palette.deepGold
                    context.fill(Path(rect), with: .color(tint.opacity(0.04 + Double(value) * 0.0125)))
                    context.stroke(Path(rect), with: .color(Wafu08Palette.deepGold.opacity(0.20)), lineWidth: 0.7)
                    var seam = Path()
                    seam.move(to: CGPoint(x: rect.minX + 1, y: rect.maxY - 1))
                    seam.addLine(to: CGPoint(x: rect.maxX - 1, y: rect.maxY - 1))
                    context.stroke(seam, with: .color(Wafu08Palette.lightGold.opacity(0.35)), lineWidth: 0.6)
                }
            }
            if folded {
                let panelWidth = size.width / 4
                for panel in 0..<4 {
                    let x = CGFloat(panel) * panelWidth
                    let colors: [Color] = panel.isMultiple(of: 2)
                        ? [Wafu08Palette.lightGold.opacity(0.42), .clear, Wafu08Palette.ink.opacity(0.14)]
                        : [Wafu08Palette.ink.opacity(0.18), .clear, Wafu08Palette.lightGold.opacity(0.25)]
                    let panelRect = CGRect(x: x, y: 0, width: panelWidth, height: size.height)
                    context.fill(Path(panelRect), with: .linearGradient(Gradient(colors: colors), startPoint: CGPoint(x: x, y: 0), endPoint: CGPoint(x: x + panelWidth, y: 0)))
                    var fold = Path()
                    fold.move(to: CGPoint(x: x, y: 0))
                    fold.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(fold, with: .color(Wafu08Palette.ink.opacity(0.18)), lineWidth: 1)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview { Wafu08Screen() }
