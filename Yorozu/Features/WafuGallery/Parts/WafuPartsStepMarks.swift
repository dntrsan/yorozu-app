import SwiftUI

private func WPStepColor(_ hex: UInt32) -> Color {
    Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
}
private func WPStepKanji(_ value: Int, formal: Bool = false) -> String {
    let simple = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    let old = ["零", "壱", "弐", "参", "四", "伍", "六", "七", "八", "九"]
    let digits = formal ? old : simple
    guard (0...99).contains(value) else { return String(value) }
    if value < 10 { return digits[value] }
    return (value / 10 == 1 ? "" : digits[value / 10]) + "十" + (value % 10 == 0 ? "" : digits[value % 10])
}
private struct WPStepMeaning: ViewModifier {
    let number: Int
    let emphasized: Bool
    func body(content: Content) -> some View {
        content.accessibilityElement(children: .ignore)
            .accessibilityLabel("手順 \(number)\(emphasized ? "、ここで初めて本文が整う" : "")")
    }
}

struct WPStepSquareSeal: View {
    var number: Int
    var emphasized: Bool = false
    var vermilion: Color = WPStepColor(0xAD493B)
    var body: some View {
        Text(WPStepKanji(number)).font(.custom("HiraMinProN-W6", size: 23)).minimumScaleFactor(0.4).lineLimit(1)
            .frame(width: 46, height: 46).foregroundStyle(emphasized ? .white : vermilion)
            .background(emphasized ? vermilion : vermilion.opacity(0.04))
            .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(vermilion, lineWidth: 1.7))
            .overlay(Rectangle().strokeBorder(emphasized ? .white.opacity(0.55) : vermilion.opacity(0.5), lineWidth: 0.6).padding(4))
            .rotationEffect(.degrees(-3)).frame(width: 52, height: 58)
            .modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepWhiteSeal: View {
    var number: Int
    var emphasized: Bool = false
    var ink: Color = WPStepColor(0x625C76)
    var body: some View {
        Text(WPStepKanji(number, formal: true)).font(.custom("HiraMinProN-W6", size: 22)).minimumScaleFactor(0.4).lineLimit(1)
            .frame(width: 42, height: 42).foregroundStyle(WPStepColor(0xFFF9EC)).background(ink, in: Circle())
            .overlay(Circle().strokeBorder(WPStepColor(0xFFF9EC).opacity(0.6), lineWidth: 0.6).padding(4))
            .padding(4).overlay(Circle().strokeBorder(ink, lineWidth: emphasized ? 1.5 : 0))
            .frame(width: 52, height: 58).modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepInkNumeral: View {
    var number: Int
    var emphasized: Bool = false
    var ink: Color = WPStepColor(0x343D42)
    var accent: Color = WPStepColor(0xAA493B)
    var body: some View {
        VStack(spacing: 3) {
            Text(String(format: "%02d", number)).font(.custom("HiraMinProN-W3", size: 30)).minimumScaleFactor(0.4).lineLimit(1)
            Rectangle().fill(emphasized ? accent : ink.opacity(0.25)).frame(width: emphasized ? 32 : 12, height: emphasized ? 3 : 1)
        }.foregroundStyle(ink).frame(width: 52, height: 58)
            .modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepMoonCircle: View {
    var number: Int
    var emphasized: Bool = false
    var ink: Color = WPStepColor(0x48616C)
    var body: some View {
        Text(String(number)).font(.system(size: 18, weight: emphasized ? .semibold : .regular, design: .serif)).minimumScaleFactor(0.4).lineLimit(1)
            .frame(width: 46, height: 46).foregroundStyle(ink)
            .background(ink.opacity(emphasized ? 0.1 : 0), in: Circle())
            .overlay(Circle().strokeBorder(ink.opacity(0.25), lineWidth: 1))
            .overlay(Circle().trim(from: 0, to: emphasized ? 1 : 0.22).stroke(ink, style: StrokeStyle(lineWidth: emphasized ? 2 : 1.5, lineCap: .round)).rotationEffect(.degrees(-90)))
            .frame(width: 52, height: 58).modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepCountingRods: View {
    var number: Int
    var emphasized: Bool = false
    var ink: Color = WPStepColor(0x795640)
    var body: some View {
        VStack(spacing: 5) {
            Group {
                if (1...9).contains(number) {
                    Canvas { context, size in
                        let count = number > 5 ? number - 5 : number
                        let spacing: CGFloat = 7
                        let left = (size.width - CGFloat(count - 1) * spacing) / 2
                        for i in 0..<count {
                            let rect = CGRect(x: left + CGFloat(i) * spacing - 1.5, y: number > 5 ? 9 : 4, width: 3, height: number > 5 ? 18 : 23)
                            context.fill(Path(roundedRect: rect, cornerRadius: 0.7), with: .color(ink))
                        }
                        if number > 5 { context.fill(Path(roundedRect: CGRect(x: 7, y: 3, width: 30, height: 3), cornerRadius: 0.7), with: .color(ink)) }
                    }
                } else {
                    Text(String(number)).font(.system(size: 22, design: .serif)).foregroundStyle(ink).minimumScaleFactor(0.4).lineLimit(1)
                }
            }.frame(width: 44, height: 30)
            Text(String(format: "%02d", number)).font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(ink)
        }.frame(width: 52, height: 58)
            .background(ink.opacity(emphasized ? 0.1 : 0))
            .overlay(alignment: .bottom) { Rectangle().fill(ink).frame(height: emphasized ? 2 : 0) }
            .modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepWoodenTag: View {
    var number: Int
    var emphasized: Bool = false
    var wood: Color = WPStepColor(0xDCC29C)
    var ink: Color = WPStepColor(0x5B422D)
    var body: some View {
        VStack(spacing: 6) {
            Circle().fill(ink.opacity(0.45)).frame(width: 3, height: 3)
            Text(WPStepKanji(number)).font(.custom("HiraMinProN-W6", size: 21)).minimumScaleFactor(0.4).lineLimit(1)
        }.frame(width: 34, height: 54).foregroundStyle(ink)
            .background(wood, in: WPStepTagShape())
            .overlay(alignment: .bottom) { Rectangle().fill(emphasized ? WPStepColor(0xAD493B) : ink.opacity(0.2)).frame(height: emphasized ? 5 : 2) }
            .frame(width: 52, height: 58).modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}
private struct WPStepTagShape: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in p.move(to: CGPoint(x: 7, y: 0)); p.addLine(to: CGPoint(x: r.maxX - 7, y: 0)); p.addLine(to: CGPoint(x: r.maxX, y: 7)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY)); p.addLine(to: CGPoint(x: 0, y: r.maxY)); p.addLine(to: CGPoint(x: 0, y: 7)); p.closeSubpath() }
    }
}

struct WPStepFoldedDiamond: View {
    var number: Int
    var emphasized: Bool = false
    var paper: Color = WPStepColor(0xDDDCC2)
    var ink: Color = WPStepColor(0x535D41)
    var body: some View {
        ZStack {
            Rectangle().fill(emphasized ? ink : paper).frame(width: 34, height: 34).rotationEffect(.degrees(45))
            Path { p in p.move(to: CGPoint(x: 2, y: 29)); p.addLine(to: CGPoint(x: 26, y: 53)); p.addLine(to: CGPoint(x: 26, y: 29)); p.closeSubpath() }
                .fill(emphasized ? .white.opacity(0.12) : ink.opacity(0.09))
            Text(String(number)).font(.custom("HiraMinProN-W6", size: 22)).minimumScaleFactor(0.4).lineLimit(1).frame(width: 30).foregroundStyle(emphasized ? WPStepColor(0xFFF9EC) : ink)
        }.frame(width: 52, height: 58).modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WPStepBraidedThread: View {
    var number: Int
    var emphasized: Bool = false
    var thread: Color = WPStepColor(0x9B625A)
    var body: some View {
        ZStack {
            Path { p in p.move(to: CGPoint(x: 0, y: 29)); p.addLine(to: CGPoint(x: 8, y: 29)); p.move(to: CGPoint(x: 44, y: 29)); p.addLine(to: CGPoint(x: 52, y: 29)) }.stroke(thread.opacity(0.6), lineWidth: 1)
            Circle().strokeBorder(thread, lineWidth: 1).frame(width: 36, height: 36)
            Circle().strokeBorder(thread.opacity(0.4), lineWidth: 1).frame(width: 30, height: 30)
            if emphasized { Circle().fill(thread).frame(width: 6, height: 6).offset(y: 18) }
            Text(WPStepKanji(number)).font(.custom("HiraMinProN-W3", size: 18)).minimumScaleFactor(0.4).lineLimit(1).frame(width: 28).foregroundStyle(thread)
        }.frame(width: 52, height: 58).modifier(WPStepMeaning(number: number, emphasized: emphasized))
    }
}

struct WafuPartsStepMarksGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("よみび  /  部品見本帳  03").font(.system(size: 11)).tracking(2)
                    Text("ひとつ、またひとつ。").font(.custom("HiraMinProN-W6", size: 28))
                    Text("手順の印 八景  /  STEP MARKS").font(.system(size: 11)).tracking(1.6)
                    Text("一から四へ。最後の印は、少し強く。").font(.system(size: 12)).foregroundStyle(.secondary)
                }.padding(.vertical, 14)
                specimen("01  角判", "朱の角印。第四手順だけ、地を満たす。") { n, _ in WPStepSquareSeal(number: n, emphasized: n == 4) }
                specimen("02  白文丸", "白抜きの漢数字。大切な印には外輪を。") { n, dark in WPStepWhiteSeal(number: n, emphasized: n == 4, ink: WPStepColor(dark ? 0x8D82A0 : 0x625C76)) }
                specimen("03  墨数字", "大きな数字と短い罫。余白を生かす。") { n, dark in WPStepInkNumeral(number: n, emphasized: n == 4, ink: WPStepColor(dark ? 0xDFE2E2 : 0x343D42)) }
                specimen("04  月輪", "細い弧が、第四手順でひとつの円になる。") { n, dark in WPStepMoonCircle(number: n, emphasized: n == 4, ink: WPStepColor(dark ? 0xACC5D0 : 0x48616C)) }
                specimen("05  算木", "棒の数で数える。小さな洋数字を添えて。") { n, dark in WPStepCountingRods(number: n, emphasized: n == 4, ink: WPStepColor(dark ? 0xD9B999 : 0x795640)) }
                specimen("06  木札", "小さな木札を並べ、朱で終点を示す。") { n, _ in WPStepWoodenTag(number: n, emphasized: n == 4) }
                specimen("07  折山", "斜めの折り面。最後の一枚を深い苔色に。") { n, _ in WPStepFoldedDiamond(number: n, emphasized: n == 4) }
                specimen("08  組紐", "二重の輪をつなぎ、結び目で要点を示す。") { n, dark in WPStepBraidedThread(number: n, emphasized: n == 4, thread: WPStepColor(dark ? 0xD4A39A : 0x9B625A)) }
                Text("よみび 1.0 ・ 手順 四で、本文が整います。").font(.system(size: 11)).foregroundStyle(.secondary)
            }.padding(20).frame(maxWidth: 390)
        }.background(WPStepColor(0xF2EFEB)).foregroundStyle(WPStepColor(0x343D42)).preferredColorScheme(.light)
    }
    private func specimen<Mark: View>(_ title: String, _ note: String, @ViewBuilder mark: (Int, Bool) -> Mark) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.custom("HiraMinProN-W6", size: 19))
            Text(note).font(.system(size: 12)).foregroundStyle(.secondary)
            ForEach([false, true], id: \.self) { dark in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dark ? "墨地" : "白地").font(.system(size: 9)).tracking(2)
                    HStack(spacing: 0) { ForEach(1...4, id: \.self) { number in mark(number, dark).frame(maxWidth: .infinity) } }
                    Text("手順 四  /  「ぁあ」から「よみび」を選ぶ").font(.system(size: 10)).fixedSize(horizontal: false, vertical: true)
                }.foregroundStyle(WPStepColor(dark ? 0xC9CCCD : 0x6D7476)).padding(16).frame(maxWidth: .infinity).background(WPStepColor(dark ? 0x252A2E : 0xFFFCF7))
            }
        }
    }
}

#Preview { WafuPartsStepMarksGallery() }
