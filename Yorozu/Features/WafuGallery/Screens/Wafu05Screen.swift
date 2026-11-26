import SwiftUI

private enum Wafu05Palette {
    static let sand = Color(red: 0.95, green: 0.94, blue: 0.90)
    static let paper = Color(red: 0.99, green: 0.98, blue: 0.95)
    static let moss = Color(red: 0.19, green: 0.28, blue: 0.22)
    static let ink = Color(red: 0.19, green: 0.22, blue: 0.20)
    static let stone = Color(red: 0.39, green: 0.42, blue: 0.38)
    static let line = Color(red: 0.81, green: 0.81, blue: 0.75)
    static let pale = Color(red: 0.89, green: 0.91, blue: 0.85)
}

struct Wafu05Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extensionState: ExtState = .on { didSet { WafuHaptics.tap() } }
    private var statusTitle: String {
        switch extensionState {
        case .on: return "読む準備が、整いました"
        case .off: return "拡張は、オフになっています"
        case .checking: return "拡張の状態を、確認中です"
        }
    }

    private var statusDetail: String {
        switch extensionState {
        case .on: return "よみびの拡張はオンです"
        case .off: return "下の手順で、よみびをオンに"
        case .checking: return "確認が終わるまでお待ちください"
        }
    }

    private var statusIcon: String {
        switch extensionState {
        case .on: return "checkmark"
        case .off: return "power"
        case .checking: return "ellipsis"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                hero
                status
                guide
                permission
                Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) {
                    HStack(spacing: 12) {
                        Image(systemName: "safari")
                        Text("Safari を開く").font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .padding(20)
                    .foregroundStyle(Wafu05Palette.paper)
                    .background(Wafu05Palette.moss, in: RoundedRectangle(cornerRadius: 8))
                }
                features
                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(.system(size: 10))
                    .foregroundStyle(Wafu05Palette.stone)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
            .padding(.bottom, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Wafu05Palette.sand)
        .foregroundStyle(Wafu05Palette.ink)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("余白を、読む。").font(.custom("HiraMinProN-W3", size: 12)).tracking(3)
                Spacer()
                Text("はじめの手引き").font(.system(size: 10)).tracking(1)
            }
            .foregroundStyle(Wafu05Palette.stone)
            .padding(.bottom, 30)

            ZStack(alignment: .topLeading) {
                Wafu05Garden()
                    .frame(width: 190, height: 190)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, -8)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 14) {
                    Wafu05Mark().frame(width: 46, height: 46).accessibilityHidden(true)
                    Text("よみび")
                        .font(.custom("HiraMinProN-W3", size: 43))
                        .tracking(7)
                    Text("ウェブの文章を、\n本のように読む")
                        .font(.custom("HiraMinProN-W3", size: 17))
                        .lineSpacing(7)
                    HStack(spacing: 8) {
                        ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { tag in
                            Text(tag).font(.system(size: 10))
                                .foregroundStyle(Wafu05Palette.stone)
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .overlay(Capsule().stroke(Wafu05Palette.line, lineWidth: 1))
                        }
                    }
                    .padding(.top, 5)
                }
            }
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
            HStack(alignment: .center, spacing: 13) {
                Image(systemName: statusIcon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(Wafu05Palette.paper.opacity(0.4), lineWidth: 1))
                VStack(alignment: .leading, spacing: 6) {
                    Text(statusTitle).font(.custom("HiraMinProN-W3", size: 16))
                    Text(statusDetail).font(.system(size: 11)).opacity(0.8)
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(Wafu05Palette.paper)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Wafu05Palette.moss, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityHint("デザイン確認用。タップでオン、オフ、確認中の表示を切り替えます")
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("読むまでの、四歩。")
                    .font(.custom("HiraMinProN-W3", size: 22))
                Spacer()
                Text("GUIDE").font(.system(size: 9)).tracking(2)
                    .foregroundStyle(Wafu05Palette.stone)
            }
            VStack(spacing: 0) {
                Wafu05Step(number: "一", title: "Safari の設定へ", detail: "設定アプリで「アプリ」→「Safari」\n→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
                Divider().overlay(Wafu05Palette.line).padding(.horizontal, 18)
                Wafu05Step(number: "二", title: "「よみび」をオンにする", detail: "", note: nil)
                Divider().overlay(Wafu05Palette.line).padding(.horizontal, 18)
                Wafu05Step(number: "三", title: "Safari で好きな記事を開く", detail: "", note: nil)
                Wafu05Step(number: "四", title: "「ぁあ」から「よみび」を選ぶ", detail: "Safari のアドレスバーから", note: "ここで初めて本文が整う", emphasized: true)
            }
            .background(Wafu05Palette.paper, in: RoundedRectangle(cornerRadius: 8))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var permission: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle").font(.system(size: 16)).padding(.top, 2)
            VStack(alignment: .leading, spacing: 7) {
                Text("サイトごとに許可が要る").font(.system(size: 13, weight: .medium))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12)).lineSpacing(5)
            }
        }
        .foregroundStyle(Wafu05Palette.stone)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Wafu05Palette.line, lineWidth: 1))
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 17) {
            Text("文章に、静けさを。")
                .font(.custom("HiraMinProN-W3", size: 16)).padding(.bottom, 3)
            Wafu05Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu05Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu05Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
        .padding(.top, 4)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { Rectangle().fill(Wafu05Palette.line).frame(height: 1) }
    }
}

private struct Wafu05Step: View {
    let number: String
    let title: String
    let detail: String
    let note: String?
    var emphasized = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number).font(.custom("HiraMinProN-W3", size: 17))
                .foregroundStyle(emphasized ? Wafu05Palette.paper : Wafu05Palette.stone)
                .frame(width: 30, height: 30)
                .background(emphasized ? Wafu05Palette.moss : Wafu05Palette.sand, in: Circle())
            VStack(alignment: .leading, spacing: 8) {
                if emphasized {
                    Text("最後のひと手間").font(.system(size: 10, weight: .semibold)).tracking(1)
                }
                Text(title).font(.system(size: 14, weight: .medium)).fixedSize(horizontal: false, vertical: true)
                if !detail.isEmpty {
                    Text(detail).font(.system(size: 12)).lineSpacing(6)
                }
                if let note {
                    Text(note).font(.system(size: 11, weight: emphasized ? .medium : .regular))
                        .foregroundStyle(emphasized ? Wafu05Palette.moss : Wafu05Palette.stone)
                }
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(emphasized ? Wafu05Palette.pale : Color.clear)
    }
}

private struct Wafu05Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon).frame(width: 18).foregroundStyle(Wafu05Palette.moss)
            Text(text).font(.system(size: 12)).foregroundStyle(Wafu05Palette.stone)
        }
    }
}

private struct Wafu05Mark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13).fill(Wafu05Palette.moss)
            Path { path in
                path.move(to: CGPoint(x: 11, y: 13))
                path.addQuadCurve(to: CGPoint(x: 23, y: 16), control: CGPoint(x: 18, y: 12))
                path.addQuadCurve(to: CGPoint(x: 35, y: 13), control: CGPoint(x: 28, y: 12))
                path.addLine(to: CGPoint(x: 35, y: 32))
                path.addQuadCurve(to: CGPoint(x: 23, y: 35), control: CGPoint(x: 28, y: 31))
                path.addQuadCurve(to: CGPoint(x: 11, y: 32), control: CGPoint(x: 18, y: 31))
                path.closeSubpath()
                path.move(to: CGPoint(x: 23, y: 16))
                path.addLine(to: CGPoint(x: 23, y: 35))
            }
            .stroke(Wafu05Palette.paper, style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct Wafu05Garden: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.56, y: size.height * 0.46)
            for index in 0..<9 {
                let radius = CGFloat(26 + index * 8)
                let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                context.stroke(Path(ellipseIn: rect), with: .color(Wafu05Palette.line.opacity(0.8)), lineWidth: 0.8)
            }
            for index in 0..<5 {
                let y = size.height - 22 + CGFloat(index * 5)
                var line = Path()
                line.move(to: CGPoint(x: 10, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(Wafu05Palette.line.opacity(0.6)), lineWidth: 0.8)
            }
            let moss = CGRect(x: center.x - 22, y: center.y - 3, width: 62, height: 33)
            context.fill(Path(ellipseIn: moss), with: .color(Wafu05Palette.moss.opacity(0.85)))
            var rock = Path()
            rock.move(to: CGPoint(x: center.x - 18, y: center.y + 13))
            rock.addQuadCurve(to: CGPoint(x: center.x - 5, y: center.y - 22), control: CGPoint(x: center.x - 28, y: center.y - 13))
            rock.addQuadCurve(to: CGPoint(x: center.x + 25, y: center.y - 4), control: CGPoint(x: center.x + 19, y: center.y - 30))
            rock.addQuadCurve(to: CGPoint(x: center.x - 18, y: center.y + 13), control: CGPoint(x: center.x + 40, y: center.y + 20))
            context.fill(rock, with: .color(Wafu05Palette.stone))
            context.fill(Path(ellipseIn: CGRect(x: center.x + 25, y: center.y + 25, width: 21, height: 13)), with: .color(Wafu05Palette.stone.opacity(0.7)))
        }
        .clipped()
    }
}

#Preview { Wafu05Screen() }
