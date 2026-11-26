import SwiftUI

private enum Wafu06Palette {
    static let night = Color(red: 0.07, green: 0.10, blue: 0.17)
    static let stall = Color(red: 0.11, green: 0.16, blue: 0.25)
    static let curtain = Color(red: 0.17, green: 0.23, blue: 0.33)
    static let paper = Color(red: 1.00, green: 0.94, blue: 0.82)
    static let muted = Color(red: 0.67, green: 0.71, blue: 0.79)
    static let amber = Color(red: 1.00, green: 0.72, blue: 0.41)
    static let ember = Color(red: 0.71, green: 0.25, blue: 0.18)
    static let line = Color(red: 0.25, green: 0.31, blue: 0.41)
}

struct Wafu06Screen: View {
    enum ExtState { case on, off, checking }
    @State private var extensionState: ExtState = .on

    private var statusTitle: String {
        switch extensionState {
        case .on: return "よみびの灯りが、つきました"
        case .off: return "よみびの灯りは、お休み中"
        case .checking: return "灯りの状態を、確認しています"
        }
    }
    private var statusDetail: String {
        switch extensionState {
        case .on: return "拡張はオンです。お好きな記事へどうぞ。"
        case .off: return "拡張はオフです。下の手順でオンに。"
        case .checking: return "確認中です。そのままお待ちください。"
        }
    }
    private var statusBadge: String {
        switch extensionState {
        case .on: return "点灯中"
        case .off: return "消灯中"
        case .checking: return "確認中"
        }
    }
    private var statusIcon: String {
        switch extensionState {
        case .on: return "checkmark.circle.fill"
        case .off: return "power"
        case .checking: return "ellipsis.circle"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
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
                    .foregroundStyle(Wafu06Palette.night)
                    .background(Wafu06Palette.amber, in: RoundedRectangle(cornerRadius: 12))
                }
                features
                Text("よみび 1.0 ・ 設定はいつでも変えられます")
                    .font(.system(size: 10))
                    .foregroundStyle(Wafu06Palette.muted)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Wafu06Palette.paper)
        .background(Wafu06Palette.night)
        .preferredColorScheme(.dark)
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Text("夜長に、ひとつの灯り。")
                .font(.custom("HiraMinProN-W3", size: 12)).tracking(3)
                .foregroundStyle(Wafu06Palette.muted)
                .padding(.bottom, 20)
            ZStack {
                Wafu06FestivalLine().frame(height: 128).accessibilityHidden(true)
                Wafu06Lantern().frame(width: 66, height: 94).accessibilityHidden(true)
            }
            Text("よみび").font(.custom("HiraMinProN-W6", size: 40)).tracking(8)
                .padding(.top, 10)
            Text("ウェブの文章を、\n本のように読む")
                .font(.custom("HiraMinProN-W3", size: 17))
                .lineSpacing(7).multilineTextAlignment(.center)
                .padding(.top, 14)
            HStack(spacing: 8) {
                ForEach(["v1.0", "iOS 18+", "Safari"], id: \.self) { tag in
                    Text(tag).font(.system(size: 10))
                        .foregroundStyle(Wafu06Palette.muted)
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .overlay(Capsule().stroke(Wafu06Palette.line, lineWidth: 1))
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
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 7) {
                    Image(systemName: statusIcon)
                    Text(statusBadge).tracking(2)
                    Spacer()
                    Text("SAFARI EXTENSION").font(.system(size: 8)).tracking(1.5)
                        .foregroundStyle(Wafu06Palette.muted)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Wafu06Palette.amber)
                Text(statusTitle).font(.custom("HiraMinProN-W3", size: 16))
                    .foregroundStyle(Wafu06Palette.paper)
                Text(statusDetail).font(.system(size: 11))
                    .foregroundStyle(Wafu06Palette.muted)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Wafu06Palette.stall, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Wafu06Palette.amber.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityHint("デザイン確認用。タップでオン、オフ、確認中の表示を切り替えます")
    }

    private var guide: some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                ForEach(["はじめる", "四つの", "おしたく"], id: \.self) { label in
                    Text(label).font(.custom("HiraMinProN-W3", size: 16)).tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 17).padding(.bottom, 20)
                        .background(Wafu06Palette.curtain)
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 6, bottomTrailingRadius: 6))
                }
            }
            .overlay(alignment: .top) { Rectangle().fill(Wafu06Palette.amber).frame(height: 2) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("はじめる、四つのおしたく")
            .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                Wafu06Step(number: "01", title: "Safari の設定を開く", detail: "設定アプリで「アプリ」→「Safari」\n→「機能拡張」を開く", note: "設定アプリのいちばん下のほう")
                Divider().overlay(Wafu06Palette.line)
                Wafu06Step(number: "02", title: "「よみび」をオンにする", detail: "", note: nil)
                Divider().overlay(Wafu06Palette.line)
                Wafu06Step(number: "03", title: "Safari で好きな記事を開く", detail: "", note: nil)
            }
            Wafu06Step(number: "04", title: "「ぁあ」から「よみび」を選ぶ", detail: "Safari のアドレスバーから", note: "ここで初めて本文が整う", emphasized: true)
        }
    }

    private var permission: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "info.circle").font(.system(size: 16))
                .foregroundStyle(Wafu06Palette.amber).padding(.top, 2)
            VStack(alignment: .leading, spacing: 7) {
                Text("サイトごとに許可が要る")
                    .font(.system(size: 13, weight: .medium))
                Text("初めて開くサイトでは、拡張を一度許可してください")
                    .font(.system(size: 12)).lineSpacing(5)
                    .foregroundStyle(Wafu06Palette.muted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Wafu06Palette.stall, in: RoundedRectangle(cornerRadius: 10))
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(spacing: 10) {
                Rectangle().fill(Wafu06Palette.amber).frame(width: 18, height: 1)
                Text("今夜は、読む時間。")
                    .font(.custom("HiraMinProN-W3", size: 16))
            }
            .padding(.bottom, 3)
            Wafu06Feature(icon: "text.alignleft", text: "本文だけを抜き出して明朝体で組む")
            Wafu06Feature(icon: "textformat.size", text: "行間と文字の大きさを端末に合わせる")
            Wafu06Feature(icon: "bookmark", text: "読んだ位置を覚えておく")
        }
        .padding(.top, 4).padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { Rectangle().fill(Wafu06Palette.line).frame(height: 1) }
    }
}

private struct Wafu06Step: View {
    let number: String
    let title: String
    let detail: String
    let note: String?
    var emphasized = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number).font(.custom("HiraMinProN-W3", size: 24))
                .foregroundStyle(emphasized ? Wafu06Palette.ember : Wafu06Palette.amber)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 8) {
                if emphasized {
                    Text("仕上げのひと押し")
                        .font(.system(size: 10, weight: .semibold)).tracking(1)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .foregroundStyle(Wafu06Palette.paper)
                        .background(Wafu06Palette.ember, in: RoundedRectangle(cornerRadius: 3))
                }
                Text(title).font(.system(size: 14, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                if !detail.isEmpty {
                    Text(detail).font(.system(size: 12)).lineSpacing(6)
                }
                if let note {
                    Text(note).font(.system(size: 11, weight: emphasized ? .medium : .regular))
                        .foregroundStyle(emphasized ? Wafu06Palette.ember : Wafu06Palette.muted)
                }
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
        .foregroundStyle(emphasized ? Wafu06Palette.night : Wafu06Palette.paper)
        .padding(.horizontal, emphasized ? 16 : 6)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(emphasized ? Wafu06Palette.paper : Color.clear, in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct Wafu06Feature: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon).frame(width: 18).foregroundStyle(Wafu06Palette.amber)
            Text(text).font(.system(size: 12)).foregroundStyle(Wafu06Palette.muted)
        }
    }
}

private struct Wafu06Lantern: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [Wafu06Palette.amber, Wafu06Palette.paper, Wafu06Palette.amber], startPoint: .leading, endPoint: .trailing))
                .frame(width: 66, height: 76)
            Path { path in
                for y in [CGFloat(23), 35, 47, 59, 71] {
                    path.move(to: CGPoint(x: 5, y: y))
                    path.addQuadCurve(to: CGPoint(x: 61, y: y), control: CGPoint(x: 33, y: y + 5))
                }
            }
            .stroke(Wafu06Palette.ember.opacity(0.23), lineWidth: 1)
            VStack {
                RoundedRectangle(cornerRadius: 2).fill(Wafu06Palette.ember).frame(width: 30, height: 7)
                Spacer()
                RoundedRectangle(cornerRadius: 2).fill(Wafu06Palette.ember).frame(width: 30, height: 7)
            }
            .padding(.vertical, 5)
            Path { path in
                path.move(to: CGPoint(x: 19, y: 35))
                path.addQuadCurve(to: CGPoint(x: 33, y: 39), control: CGPoint(x: 26, y: 34))
                path.addQuadCurve(to: CGPoint(x: 47, y: 35), control: CGPoint(x: 40, y: 34))
                path.addLine(to: CGPoint(x: 47, y: 57))
                path.addQuadCurve(to: CGPoint(x: 33, y: 61), control: CGPoint(x: 40, y: 56))
                path.addQuadCurve(to: CGPoint(x: 19, y: 57), control: CGPoint(x: 26, y: 56))
                path.closeSubpath()
                path.move(to: CGPoint(x: 33, y: 39))
                path.addLine(to: CGPoint(x: 33, y: 61))
            }
            .stroke(Wafu06Palette.ember, style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 66, height: 94)
        .background {
            Ellipse().fill(Wafu06Palette.amber.opacity(0.12))
                .frame(width: 110, height: 110).blur(radius: 18)
        }
    }
}

private struct Wafu06FestivalLine: View {
    var body: some View {
        Canvas { context, size in
            var rope = Path()
            rope.move(to: CGPoint(x: 0, y: 10))
            rope.addQuadCurve(to: CGPoint(x: size.width, y: 10), control: CGPoint(x: size.width / 2, y: 58))
            context.stroke(rope, with: .color(Wafu06Palette.line), lineWidth: 1)
            for x in [size.width * 0.12, size.width * 0.88] {
                var cord = Path()
                cord.move(to: CGPoint(x: x, y: 20))
                cord.addLine(to: CGPoint(x: x, y: 34))
                context.stroke(cord, with: .color(Wafu06Palette.line), lineWidth: 1)
                let rect = CGRect(x: x - 9, y: 34, width: 18, height: 25)
                context.fill(RoundedRectangle(cornerRadius: 7).path(in: rect), with: .color(Wafu06Palette.amber.opacity(0.65)))
                for y in [CGFloat(41), 47, 53] {
                    var rib = Path()
                    rib.move(to: CGPoint(x: x - 7, y: y))
                    rib.addLine(to: CGPoint(x: x + 7, y: y))
                    context.stroke(rib, with: .color(Wafu06Palette.ember.opacity(0.5)), lineWidth: 0.7)
                }
            }
        }
    }
}

#Preview { Wafu06Screen() }
