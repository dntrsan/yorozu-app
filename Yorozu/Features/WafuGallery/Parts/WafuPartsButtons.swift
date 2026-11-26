import SwiftUI

// Each style can be copied with the WPButton helpers below. Use with Button or Link.
private func WPButtonColor(_ hex: UInt32) -> Color {
    Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
}

private struct WPButtonPress: ViewModifier {
    let pressed: Bool
    var depth: CGFloat = 2
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.975 : 1)
            .offset(y: pressed ? depth : 0)
            .opacity(enabled ? 1 : 0.38)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: pressed)
    }
}

struct WPButtonLacquer: ButtonStyle {
    var tint: Color = WPButtonColor(0xA83B32)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.custom("HiraMinProN-W6", size: 16))
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(WPButtonColor(0xFFF4DE))
            .background(LinearGradient(colors: [tint, tint.opacity(0.85), tint], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(.white.opacity(0.2), lineWidth: 1))
            .overlay(alignment: .top) { Capsule().fill(.white.opacity(0.28)).frame(height: 1).padding(.horizontal, 18).padding(.top, 4) }
            .shadow(color: tint.opacity(configuration.isPressed ? 0.08 : 0.25), radius: configuration.isPressed ? 1 : 6, y: configuration.isPressed ? 1 : 4)
            .brightness(configuration.isPressed ? -0.09 : 0)
            .modifier(WPButtonPress(pressed: configuration.isPressed))
    }
}

struct WPButtonInkOutline: ButtonStyle {
    var ink: Color = WPButtonColor(0x343936)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.custom("HiraMinProN-W3", size: 16))
            .frame(maxWidth: .infinity, minHeight: 52).foregroundStyle(ink)
            .background(ink.opacity(configuration.isPressed ? 0.12 : 0.015))
            .overlay(Rectangle().strokeBorder(ink, lineWidth: 1))
            .overlay(Rectangle().strokeBorder(ink.opacity(0.3), lineWidth: 0.5).padding(4))
            .contentShape(Rectangle())
            .modifier(WPButtonPress(pressed: configuration.isPressed, depth: 0))
    }
}

struct WPButtonFoldedPaper: ButtonStyle {
    var paper: Color = WPButtonColor(0xF0E7D2)
    var ink: Color = WPButtonColor(0x5D6249)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.custom("HiraMinProN-W6", size: 16))
            .frame(maxWidth: .infinity, minHeight: 54).foregroundStyle(ink)
            .background(paper)
            .clipShape(WPButtonCutCorner())
            .overlay(alignment: .topTrailing) { WPButtonFold().fill(ink.opacity(0.18)).frame(width: 15, height: 15) }
            .overlay(alignment: .bottom) { Rectangle().fill(ink.opacity(0.15)).frame(height: 2).padding(.trailing, 1) }
            .brightness(configuration.isPressed ? -0.045 : 0)
            .modifier(WPButtonPress(pressed: configuration.isPressed, depth: 1))
    }
}

private struct WPButtonCutCorner: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in
            p.move(to: r.origin); p.addLine(to: CGPoint(x: r.maxX - 15, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.minY + 15)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.closeSubpath()
        }
    }
}
private struct WPButtonFold: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in p.move(to: r.origin); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY)); p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.closeSubpath() }
    }
}

struct WPButtonIndigoStitch: ButtonStyle {
    var indigo: Color = WPButtonColor(0x264D63)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 56).foregroundStyle(WPButtonColor(0xF3EDDE))
            .background(indigo).clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(WPButtonColor(0xE3D7BA).opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [3, 4])).padding(5))
            .brightness(configuration.isPressed ? 0.08 : 0)
            .modifier(WPButtonPress(pressed: configuration.isPressed, depth: 1))
    }
}

struct WPButtonCedarTag: ButtonStyle {
    var wood: Color = WPButtonColor(0xDBC09A)
    var ink: Color = WPButtonColor(0x513D29)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.custom("HiraMinProN-W6", size: 16))
            .frame(maxWidth: .infinity, minHeight: 54).foregroundStyle(ink)
            .background(wood, in: RoundedRectangle(cornerRadius: 4))
            .background(alignment: .bottom) { RoundedRectangle(cornerRadius: 4).fill(ink.opacity(0.5)).offset(y: configuration.isPressed ? 1 : 4) }
            .overlay { Canvas { context, size in
                for y in stride(from: 9.0, to: Double(size.height), by: 12) {
                    var line = Path(); line.move(to: CGPoint(x: 0, y: y)); line.addQuadCurve(to: CGPoint(x: size.width, y: y + 2), control: CGPoint(x: size.width * 0.6, y: y - 6))
                    context.stroke(line, with: .color(ink.opacity(0.07)), lineWidth: 1)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 4)).allowsHitTesting(false) }
            .overlay(alignment: .leading) { Circle().fill(ink.opacity(0.4)).frame(width: 4, height: 4).padding(.leading, 12) }
            .modifier(WPButtonPress(pressed: configuration.isPressed, depth: 3))
    }
}

struct WPButtonVermilionSeal: ButtonStyle {
    var tint: Color = WPButtonColor(0xB44838)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 20, weight: .medium)).frame(width: 56, height: 56)
            .foregroundStyle(configuration.isPressed ? .white : tint)
            .background(configuration.isPressed ? tint : tint.opacity(0.07), in: Circle())
            .overlay(Circle().strokeBorder(tint, lineWidth: 1.5))
            .overlay(Circle().strokeBorder(tint.opacity(0.45), lineWidth: 0.6).padding(4))
            .contentShape(Circle()).modifier(WPButtonPress(pressed: configuration.isPressed, depth: 0))
    }
}

struct WPButtonMoonRing: ButtonStyle {
    var gold: Color = WPButtonColor(0xC4A66A)
    var ground: Color = WPButtonColor(0x262B30)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 19, weight: .regular)).frame(width: 48, height: 48)
            .foregroundStyle(gold).background(ground, in: Circle())
            .overlay(Circle().trim(from: 0.04, to: configuration.isPressed ? 1 : 0.79).stroke(gold, style: StrokeStyle(lineWidth: 1.5, lineCap: .round)).rotationEffect(.degrees(-90)).padding(3))
            .contentShape(Circle()).modifier(WPButtonPress(pressed: configuration.isPressed, depth: 0))
    }
}

struct WPButtonBookmark: ButtonStyle {
    var tint: Color = WPButtonColor(0x65745A)
    var ink: Color = WPButtonColor(0x343936)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 15, weight: .medium))
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading).padding(.leading, 24)
            .foregroundStyle(ink).background(tint.opacity(configuration.isPressed ? 0.18 : 0.07))
            .overlay(alignment: .leading) { Rectangle().fill(tint).frame(width: configuration.isPressed ? 8 : 4) }
            .overlay(alignment: .trailing) { Image(systemName: "arrow.right").font(.system(size: 13)).foregroundStyle(tint).padding(.trailing, 16) }
            .modifier(WPButtonPress(pressed: configuration.isPressed, depth: 0))
    }
}

struct WafuPartsButtonsGallery: View {
    @State private var feedback = "押して、手ざわりを確かめる"
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("よみび  /  部品見本帳  01").font(.system(size: 11, weight: .medium)).tracking(2)
                    Text("押す、という所作。").font(.custom("HiraMinProN-W6", size: 29))
                    Text("ボタン八景  /  BUTTONS").font(.system(size: 11)).tracking(2)
                    Text(feedback).font(.system(size: 12)).foregroundStyle(.secondary).accessibilityAddTraits(.updatesFrequently)
                }.padding(.vertical, 14)
                specimen("01  漆朱", "艶をひとすじ。主役になる入口。") { _ in
                    Link(destination: URL(string: "https://www.apple.com/jp/safari/")!) { Label("Safari を開く", systemImage: "arrow.up.right") }.buttonStyle(WPButtonLacquer())
                }
                specimen("02  墨枠", "二重の細線。静かな副ボタン。") { dark in
                    Button("設定を確認する") { feedback = "墨枠を押しました" }.buttonStyle(WPButtonInkOutline(ink: WPButtonColor(dark ? 0xE4DDCE : 0x343936)))
                }
                specimen("03  折紙", "角を折って、次の手順へ。") { _ in
                    Button("手順を見る") { feedback = "折紙を押しました" }.buttonStyle(WPButtonFoldedPaper())
                }
                specimen("04  藍布", "生成りの縫い目を巡らせる。") { _ in
                    Button("Safari を開く") { feedback = "藍布を押しました" }.buttonStyle(WPButtonIndigoStitch())
                }
                specimen("05  木札", "木目と厚み。押すと深く沈む。") { _ in
                    Button("よみびをオンにする") { feedback = "木札を押しました" }.buttonStyle(WPButtonCedarTag())
                }
                specimen("06  朱印丸", "押す間だけ朱が満ちる、小さな印。") { _ in
                    Button { feedback = "朱印丸を押しました" } label: { Image(systemName: "checkmark") }.buttonStyle(WPButtonVermilionSeal()).accessibilityLabel("手順を完了する")
                }
                specimen("07  月輪丸", "金の弧が閉じる、読み進める合図。") { _ in
                    Button { feedback = "月輪丸を押しました" } label: { Image(systemName: "arrow.right") }.buttonStyle(WPButtonMoonRing()).accessibilityLabel("次の手順へ")
                }
                specimen("08  栞", "左端の色が、読書の続きへ誘う。") { dark in
                    Button("続きから読む") { feedback = "栞を押しました" }.buttonStyle(WPButtonBookmark(tint: WPButtonColor(dark ? 0xA6B493 : 0x65745A), ink: WPButtonColor(dark ? 0xE4DDCE : 0x343936)))
                }
                Text("よみび 1.0 ・ 小さな所作に、手ざわりを。").font(.system(size: 11)).foregroundStyle(.secondary)
            }.padding(20).frame(maxWidth: 390)
        }.background(WPButtonColor(0xF5F1E8)).foregroundStyle(WPButtonColor(0x343936)).preferredColorScheme(.light)
    }
    private func specimen<V: View>(_ name: String, _ note: String, @ViewBuilder content: (Bool) -> V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.custom("HiraMinProN-W6", size: 19))
            Text(note).font(.system(size: 12)).foregroundStyle(.secondary)
            ForEach([false, true], id: \.self) { dark in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dark ? "墨地" : "白地").font(.system(size: 9)).tracking(2).foregroundStyle(WPButtonColor(dark ? 0xC7C4BB : 0x726E63))
                    HStack { Spacer(minLength: 0); content(dark); Spacer(minLength: 0) }
                }.padding(18).frame(maxWidth: .infinity).background(WPButtonColor(dark ? 0x222827 : 0xFFFCF5))
            }
        }
    }
}

#Preview { WafuPartsButtonsGallery() }
