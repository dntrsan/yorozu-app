import SwiftUI

private func WPCardColor(_ hex: UInt32) -> Color {
    Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
}

private struct WPCardCopy: View {
    let title: String
    let detail: String
    var ink: Color = WPCardColor(0x393C32)
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.custom("HiraMinProN-W6", size: 18)).fixedSize(horizontal: false, vertical: true)
            Text(detail).font(.system(size: 13)).lineSpacing(5).fixedSize(horizontal: false, vertical: true).opacity(0.82)
        }.frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(ink)
    }
}

struct WPCardKozoPaper: View {
    var title: String
    var detail: String
    var caption: String = "読むための、ひと手間"
    var paper: Color = WPCardColor(0xF4EBD9)
    var ink: Color = WPCardColor(0x514B3C)
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(caption).font(.system(size: 10)).tracking(2).foregroundStyle(ink.opacity(0.8))
            WPCardCopy(title: title, detail: detail, ink: ink)
        }.padding(22).background {
            ZStack {
                paper
                Canvas { context, size in
                    for i in 0..<55 {
                        let x = CGFloat((i * 47 + 13) % 307) / 307 * size.width
                        let y = CGFloat((i * 31 + 7) % 173) / 173 * size.height
                        var fiber = Path(); fiber.move(to: CGPoint(x: x, y: y)); fiber.addLine(to: CGPoint(x: x + 4, y: y + 1.5))
                        context.stroke(fiber, with: .color(ink.opacity(0.075)), lineWidth: 0.5)
                    }
                }
            }.clipShape(RoundedRectangle(cornerRadius: 3))
        }.overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(ink.opacity(0.12), lineWidth: 0.5))
    }
}

enum WPCardExtState: CaseIterable {
    case on, off, checking
    var title: String {
        switch self { case .on: "よみびはオンです"; case .off: "よみびはオフです"; case .checking: "設定を確認中です" }
    }
    var detail: String {
        switch self { case .on: "Safari で好きな記事を開いてください"; case .off: "設定で「よみび」をオンにしてください"; case .checking: "拡張の状態を確認しています" }
    }
    var symbol: String { switch self { case .on: "checkmark"; case .off: "minus"; case .checking: "ellipsis" } }
    var tint: Color { switch self { case .on: WPCardColor(0xBDD1AC); case .off: WPCardColor(0xE0B590); case .checking: WPCardColor(0xC5D0DF) } }
    var next: Self { switch self { case .on: .off; case .off: .checking; case .checking: .on } }
}

struct WPCardBlackLacquer: View {
    var state: WPCardExtState
    var caption: String = "拡張の状態"
    var gold: Color = WPCardColor(0xBDA26B)
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(caption).font(.system(size: 10)).tracking(2)
                Spacer()
                Image(systemName: state.symbol).font(.system(size: 13, weight: .semibold)).frame(width: 26, height: 26)
                    .foregroundStyle(state.tint).overlay(Circle().strokeBorder(state.tint.opacity(0.5)))
            }.foregroundStyle(gold)
            WPCardCopy(title: state.title, detail: state.detail, ink: WPCardColor(0xF4E9D3))
            Rectangle().fill(gold.opacity(0.5)).frame(height: 1)
        }.padding(22)
            .background(LinearGradient(colors: [WPCardColor(0x33332F), WPCardColor(0x191D1B)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(gold.opacity(0.25), lineWidth: 1))
            .accessibilityElement(children: .combine)
    }
}

struct WPCardCedarBoard: View {
    var title: String
    var detail: String
    var step: String = "手順 一"
    var wood: Color = WPCardColor(0xD7B68A)
    var ink: Color = WPCardColor(0x4D3827)
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack { Text(step).font(.custom("HiraMinProN-W6", size: 12)); Spacer(); Circle().fill(ink.opacity(0.5)).frame(width: 5, height: 5) }
            WPCardCopy(title: title, detail: detail, ink: ink)
        }.foregroundStyle(ink).padding(22).background {
            ZStack {
                wood
                Canvas { context, size in
                    for i in 0..<12 {
                        let x = CGFloat(i) * size.width / 11
                        var grain = Path(); grain.move(to: CGPoint(x: x, y: 0)); grain.addCurve(to: CGPoint(x: x + 3, y: size.height), control1: CGPoint(x: x - 12, y: size.height * 0.3), control2: CGPoint(x: x + 13, y: size.height * 0.7))
                        context.stroke(grain, with: .color(ink.opacity(0.07)), lineWidth: 1)
                    }
                }
            }.clipShape(RoundedRectangle(cornerRadius: 5))
        }.overlay(alignment: .bottom) { Rectangle().fill(ink.opacity(0.25)).frame(height: 3) }
    }
}

struct WPCardIndigoCloth: View {
    var title: String
    var detail: String
    var symbol: String = "text.alignleft"
    var indigo: Color = WPCardColor(0x294957)
    var thread: Color = WPCardColor(0xE7DCC2)
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: symbol).font(.system(size: 19)).foregroundStyle(thread).accessibilityHidden(true)
            WPCardCopy(title: title, detail: detail, ink: thread)
        }.padding(26).background(indigo, in: RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(thread.opacity(0.45), style: StrokeStyle(lineWidth: 1, dash: [3, 5])).padding(7))
    }
}

struct WPCardKihadaNotice: View {
    var title: String
    var detail: String
    var badge: String = "ご注意"
    var paper: Color = WPCardColor(0xF0DCA3)
    var ink: Color = WPCardColor(0x584725)
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 7) {
                Image(systemName: "exclamationmark.triangle").accessibilityHidden(true)
                Text(badge)
            }.font(.system(size: 11, weight: .medium))
            WPCardCopy(title: title, detail: detail, ink: ink)
        }.foregroundStyle(ink).padding(22).background(paper)
            .overlay(alignment: .leading) { Rectangle().fill(WPCardColor(0xAE7B32)).frame(width: 4) }
            .overlay(alignment: .topTrailing) {
                Path { p in p.move(to: .zero); p.addLine(to: CGPoint(x: 18, y: 18)); p.addLine(to: CGPoint(x: 0, y: 18)); p.closeSubpath() }
                    .fill(ink.opacity(0.14)).frame(width: 18, height: 18)
            }
    }
}

struct WPCardInkMargin: View {
    var title: String
    var detail: String
    var caption: String = "よみびについて"
    var ink: Color = WPCardColor(0x424940)
    var paper: Color = WPCardColor(0xFBFAF5)
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Rectangle().fill(ink).frame(width: 26, height: 2)
                Text(caption).font(.system(size: 10)).tracking(1)
            }.foregroundStyle(ink)
            WPCardCopy(title: title, detail: detail, ink: ink)
        }.padding(.vertical, 28).padding(.horizontal, 24).background(paper)
            .overlay(alignment: .bottom) { Rectangle().fill(ink.opacity(0.2)).frame(height: 1) }
    }
}

struct WPCardGoldDust: View {
    var title: String
    var detail: String
    var caption: String = "ここで、本文が整います"
    var gold: Color = WPCardColor(0xCCB67A)
    var ground: Color = WPCardColor(0x353E36)
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(caption).font(.system(size: 10)).tracking(1).foregroundStyle(gold)
            WPCardCopy(title: title, detail: detail, ink: WPCardColor(0xF4EDD9))
        }.padding(25).background(ground)
            .overlay(Rectangle().strokeBorder(gold.opacity(0.55), lineWidth: 0.5).padding(6))
            .overlay(alignment: .topTrailing) {
                Canvas { context, size in
                    for i in 0..<16 {
                        let x = CGFloat((i * 19) % 70), y = CGFloat((i * 13) % 34)
                        context.fill(Path(CGRect(x: x, y: y, width: i % 3 == 0 ? 3 : 1.5, height: 1.5)), with: .color(gold.opacity(0.6)))
                    }
                }.frame(width: 70, height: 34).padding(10).allowsHitTesting(false)
            }
    }
}

struct WPCardFoldedLetter: View {
    var title: String
    var detail: String
    var caption: String = "よみびからのお便り"
    var paper: Color = WPCardColor(0xF1F0E8)
    var accent: Color = WPCardColor(0x9A594D)
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(caption).font(.system(size: 10)).tracking(1).foregroundStyle(accent)
            WPCardCopy(title: title, detail: detail, ink: WPCardColor(0x4B504A))
        }.padding(.top, 32).padding(.horizontal, 22).padding(.bottom, 24)
            .background(paper)
            .overlay(alignment: .top) {
                GeometryReader { geometry in
                    Path { p in p.move(to: .zero); p.addLine(to: CGPoint(x: geometry.size.width / 2, y: 17)); p.addLine(to: CGPoint(x: geometry.size.width, y: 0)) }
                        .stroke(accent.opacity(0.25), lineWidth: 0.7)
                }.frame(height: 18)
            }
            .overlay(alignment: .bottomTrailing) { RoundedRectangle(cornerRadius: 1).strokeBorder(accent.opacity(0.6), lineWidth: 1).frame(width: 12, height: 12).rotationEffect(.degrees(-6)).padding(10) }
    }
}

struct WafuPartsCardsGallery: View {
    @State private var state: WPCardExtState = .on { didSet { WafuHaptics.tap() } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("よみび  /  部品見本帳  02").font(.system(size: 11)).tracking(2)
                    Text("ことばを置く、地。").font(.custom("HiraMinProN-W6", size: 29))
                    Text("カード八景  /  CARDS").font(.system(size: 11)).tracking(2)
                }.padding(.vertical, 14)
                specimen("01  楮紙", "繊維をすこし。説明をやさしく受け止める。") { _ in
                    WPCardKozoPaper(title: "ウェブの文章を、\n本のように読む", detail: "本文だけを抜き出して明朝体で組む")
                }
                specimen("02  黒漆", "落ち着いた光沢で、現在の状態を伝える。") { _ in
                    Button { state = state.next } label: { WPCardBlackLacquer(state: state) }.buttonStyle(.plain).accessibilityHint("タップでオン、オフ、確認中の見本を切り替えます")
                }
                specimen("03  杉板", "縦の木目と留め穴。手順を一枚ずつ。") { _ in
                    WPCardCedarBoard(title: "設定アプリを開く", detail: "「アプリ」→「Safari」→「機能拡張」\n設定アプリのいちばん下のほう")
                }
                specimen("04  藍染", "縫い代で囲む、日々の機能説明。") { _ in
                    WPCardIndigoCloth(title: "読みやすさを整える", detail: "行間と文字の大きさを端末に合わせる")
                }
                specimen("05  黄檗", "やわらかな黄で、見落とせない注意を。") { _ in
                    WPCardKihadaNotice(title: "サイトごとに許可が要る", detail: "初めて開くサイトでは、拡張を一度許可してください")
                }
                specimen("06  墨罫", "罫線と余白だけ。長い説明にも。") { dark in
                    WPCardInkMargin(title: "読んだ位置を覚えておく", detail: "ウェブの文章を、本のように読む", ink: WPCardColor(dark ? 0xE1E2D8 : 0x424940), paper: WPCardColor(dark ? 0x2B312D : 0xFBFAF5))
                }
                specimen("07  金砂", "手順四を、控えめな金の枠で際立たせる。") { _ in
                    WPCardGoldDust(title: "「ぁあ」から\n「よみび」を選ぶ", detail: "Safari のアドレスバーから選べます", caption: "手順 四  /  ここで初めて本文が整う")
                }
                specimen("08  折便り", "封筒の折り目。最後に添えるひとこと。") { _ in
                    WPCardFoldedLetter(title: "設定はいつでも\n変えられます", detail: "よみび 1.0 ・ Safari")
                }
                Text("よみび 1.0 ・ ことばに合わせて、地を選ぶ。").font(.system(size: 11)).foregroundStyle(.secondary)
            }.padding(20).frame(maxWidth: 390)
        }.background(WPCardColor(0xEEEEE6)).foregroundStyle(WPCardColor(0x393C32)).preferredColorScheme(.light)
    }
    private func specimen<V: View>(_ title: String, _ detail: String, @ViewBuilder content: @escaping (Bool) -> V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.custom("HiraMinProN-W6", size: 19))
            Text(detail).font(.system(size: 12)).foregroundStyle(.secondary)
            ForEach([false, true], id: \.self) { dark in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dark ? "墨地" : "白地").font(.system(size: 9)).tracking(2).foregroundStyle(WPCardColor(dark ? 0xC4C9BD : 0x72776B))
                    content(dark)
                }.padding(16).frame(maxWidth: .infinity).background(WPCardColor(dark ? 0x222923 : 0xFAFBF5))
            }
        }
    }
}

#Preview { WafuPartsCardsGallery() }
