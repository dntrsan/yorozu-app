import SwiftUI

struct Wafu02Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extensionState: ExtState = .on

    private var stateTitle: String {
        switch extensionState {
        case .on: return "拡張はオンです"
        case .off: return "拡張はオフです"
        case .checking: return "拡張を確認中です"
        }
    }

    private var stateDetail: String {
        switch extensionState {
        case .on: return "さあ、好きな記事を一つ。"
        case .off: return "下の手順でオンにしましょう。"
        case .checking: return "設定の状態を確認しています。"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                status.padding(.top, 30)
                guide.padding(.top, 36)
                permission.padding(.top, 22)
                safariLink.padding(.top, 22)
                benefits.padding(.top, 32)
                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(.system(size: 10))
                    .foregroundStyle(Wafu02Palette.mist)
                    .padding(.top, 36)
            }
            .padding(.horizontal, 24)
            .padding(.top, 34)
            .padding(.bottom, 32)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .background(Wafu02Cloth())
        }
        .background(Wafu02Palette.deep.ignoresSafeArea())
        .foregroundStyle(Wafu02Palette.white)
        .preferredColorScheme(.dark)
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Text("YOMIBI / READING COMPANION")
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(Wafu02Palette.mist)
            Wafu02BookMark()
                .frame(width: 72, height: 72)
                .padding(.top, 29)
                .accessibilityHidden(true)
            Text("よみび")
                .font(.system(size: 42, weight: .medium, design: .rounded))
                .tracking(10)
                .padding(.leading, 10)
                .padding(.top, 18)
            Text("ウェブの文章を、本のように読む")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.top, 12)
            HStack(spacing: 7) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { label in
                    Text(label).font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Wafu02Palette.white.opacity(0.09), in: Capsule())
                        .overlay(Capsule().stroke(Wafu02Palette.white.opacity(0.2), lineWidth: 0.7))
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private var status: some View {
        Button {
            switch extensionState {
            case .on: extensionState = .off
            case .off: extensionState = .checking
            case .checking: extensionState = .on
            }
        } label: {
            HStack(spacing: 13) {
                Image(systemName: extensionState == .on ? "checkmark" : extensionState == .off ? "minus" : "ellipsis")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 34, height: 34)
                    .foregroundStyle(Wafu02Palette.deep)
                    .background(Wafu02Palette.white, in: Circle())
                VStack(alignment: .leading, spacing: 6) {
                    Text(stateTitle).font(.system(size: 16, weight: .semibold))
                    Text(stateDetail).font(.system(size: 11))
                        .foregroundStyle(Wafu02Palette.mist)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Wafu02Palette.mid, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Wafu02Palette.edge, lineWidth: 0.8))
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityHint("デザイン確認用。タップすると表示状態が切り替わります")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("読むまでの、ひと手間。")
                    .font(.system(size: 20, weight: .medium))
                Spacer(minLength: 8)
                Text("4 STEPS").font(.system(size: 9, weight: .medium)).tracking(1)
                    .foregroundStyle(Wafu02Palette.mist)
            }
            .padding(.bottom, 6)
            Wafu02Step(number: "01", title: "設定から Safari へ", detail: "設定アプリで「アプリ」→「Safari」→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
            Wafu02Step(number: "02", title: "「よみび」をオンにする")
            Wafu02Step(number: "03", title: "Safari で好きな記事を開く")
            Wafu02Step(number: "04", title: "「ぁあ」から「よみび」を選ぶ", detail: "アドレスバーの「ぁあ」から「よみび」を選ぶ", note: "ここで初めて本文が整う", highlighted: true)
        }
    }

    private var permission: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "lock.open").font(.system(size: 16))
                .padding(.top, 2).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 7) {
                Text("サイトごとに許可が要る").font(.system(size: 13, weight: .semibold))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12)).lineSpacing(6)
                    .foregroundStyle(Wafu02Palette.mist)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu02Palette.deep.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Wafu02Palette.edge, lineWidth: 0.7))
    }

    private var safariLink: some View {
        Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
            HStack(spacing: 10) {
                Image(systemName: "safari").font(.system(size: 20, weight: .light))
                Text("Safari を開く").font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 14))
            }
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(Wafu02Palette.deep)
            .background(Wafu02Palette.white, in: Capsule())
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 17) {
            Wafu02Benefit(symbol: "doc.text", text: "本文だけを抜き出して明朝体で組む")
            Wafu02Benefit(symbol: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu02Benefit(symbol: "bookmark", text: "読んだ位置を覚えておく")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}

private enum Wafu02Palette {
    static let deep = Color(red: 0.039, green: 0.153, blue: 0.259)
    static let mid = Color(red: 0.082, green: 0.251, blue: 0.388)
    static let bright = Color(red: 0.141, green: 0.373, blue: 0.533)
    static let white = Color(red: 0.949, green: 0.969, blue: 0.949)
    static let mist = Color(red: 0.718, green: 0.812, blue: 0.847)
    static let edge = Color(red: 0.275, green: 0.427, blue: 0.541)
}

private struct Wafu02Step: View {
    let number: String
    let title: String
    var detail: String? = nil
    var note: String? = nil
    var highlighted = false

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .frame(width: 30, height: 30)
                .foregroundStyle(highlighted ? Wafu02Palette.deep : Wafu02Palette.mist)
                .background(highlighted ? Wafu02Palette.white : Wafu02Palette.deep, in: Circle())
            VStack(alignment: .leading, spacing: 9) {
                if highlighted {
                    Text("仕上げは、記事の上で。")
                        .font(.system(size: 10, weight: .medium)).tracking(0.5)
                }
                Text(title).font(.system(size: 14, weight: .medium)).lineSpacing(5)
                    .padding(.top, highlighted ? 0 : 4)
                if let detail {
                    Text(detail).font(.system(size: 12)).lineSpacing(7)
                        .foregroundStyle(highlighted ? Wafu02Palette.white : Wafu02Palette.mist)
                }
                if let note {
                    Text(note).font(.system(size: 10, weight: highlighted ? .medium : .regular))
                        .lineSpacing(5)
                        .foregroundStyle(highlighted ? Wafu02Palette.white : Wafu02Palette.mist)
                        .padding(.top, highlighted ? 4 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(highlighted ? Wafu02Palette.bright : Wafu02Palette.mid.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(highlighted ? Wafu02Palette.mist : Wafu02Palette.edge.opacity(0.6), lineWidth: highlighted ? 1 : 0.7))
    }
}

private struct Wafu02Benefit: View {
    let symbol: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).font(.system(size: 16, weight: .light))
                .frame(width: 20).accessibilityHidden(true)
            Text(text).font(.system(size: 11)).lineSpacing(5)
        }
        .foregroundStyle(Wafu02Palette.mist)
    }
}

private struct Wafu02BookMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 23)
                .fill(Wafu02Palette.white.opacity(0.1))
            RoundedRectangle(cornerRadius: 23)
                .stroke(Wafu02Palette.white.opacity(0.5), lineWidth: 1)
            Canvas { context, _ in
                var pages = Path()
                pages.move(to: CGPoint(x: 16, y: 24))
                pages.addQuadCurve(to: CGPoint(x: 36, y: 28), control: CGPoint(x: 28, y: 20))
                pages.addQuadCurve(to: CGPoint(x: 56, y: 24), control: CGPoint(x: 45, y: 20))
                pages.addLine(to: CGPoint(x: 56, y: 48))
                pages.addQuadCurve(to: CGPoint(x: 36, y: 53), control: CGPoint(x: 44, y: 46))
                pages.addQuadCurve(to: CGPoint(x: 16, y: 48), control: CGPoint(x: 28, y: 46))
                pages.closeSubpath()
                context.fill(pages, with: .color(Wafu02Palette.white))
                var spine = Path()
                spine.move(to: CGPoint(x: 36, y: 29))
                spine.addLine(to: CGPoint(x: 36, y: 50))
                context.stroke(spine, with: .color(Wafu02Palette.deep), lineWidth: 1.2)
            }
            Circle().fill(Wafu02Palette.white).frame(width: 4, height: 4).offset(y: -22)
        }
    }
}

private struct Wafu02Cloth: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Wafu02Palette.deep
                Wafu02Dye(radius: 158)
                    .position(x: proxy.size.width * 0.91, y: 133)
                Wafu02Dye(radius: 116)
                    .position(x: -12, y: 648)
                Canvas { context, size in
                    var weave = Path()
                    for x in stride(from: CGFloat(0), to: size.width, by: 6) {
                        weave.move(to: CGPoint(x: x, y: 0))
                        weave.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    for y in stride(from: CGFloat(0), to: size.height, by: 6) {
                        weave.move(to: CGPoint(x: 0, y: y))
                        weave.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(weave, with: .color(Wafu02Palette.white.opacity(0.025)), lineWidth: 0.5)
                }
            }
            .clipped()
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

private struct Wafu02Dye: View {
    let radius: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(colors: [Wafu02Palette.bright.opacity(0.55), Wafu02Palette.bright.opacity(0)], center: .center, startRadius: 0, endRadius: radius))
            ForEach(0..<7) { index in
                Wafu02DyeRing(phase: Double(index) * 0.7)
                    .stroke(Wafu02Palette.mist.opacity(index.isMultiple(of: 2) ? 0.17 : 0.10), lineWidth: index.isMultiple(of: 2) ? 8 : 4)
                    .frame(width: radius * (0.42 + CGFloat(index) * 0.23), height: radius * (0.42 + CGFloat(index) * 0.23))
                    .blur(radius: index.isMultiple(of: 2) ? 3 : 1.5)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

private struct Wafu02DyeRing: Shape {
    let phase: Double
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for step in 0...180 {
            let angle = Double(step) / 180 * Double.pi * 2
            let wobble = 1 + 0.045 * sin(angle * 9 + phase) + 0.022 * cos(angle * 17 - phase)
            let x = rect.midX + CGFloat(cos(angle) * wobble) * rect.width * 0.47
            let y = rect.midY + CGFloat(sin(angle) * wobble) * rect.height * 0.47
            if step == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

#Preview { Wafu02Screen() }
