import Foundation

/// ホームのあいさつ。時間帯と曜日に合わせた候補から1つ選ぶ。
/// 文中の {n} にユーザーの呼び方が入る。名前が無いときは「、{n}」「{n}、」を消して使うので、
/// {n} は必ずこのどちらかの形で書くこと。
enum Greeting {
    static func pick(at date: Date = Date(), calendar: Calendar = .current) -> String {
        candidates(at: date, calendar: calendar).randomElement() ?? "こんにちは、{n}"
    }

    static func render(_ template: String, name: String?) -> String {
        if let name {
            return template.replacingOccurrences(of: "{n}", with: name)
        }
        return template
            .replacingOccurrences(of: "、{n}", with: "")
            .replacingOccurrences(of: "{n}、", with: "")
            .replacingOccurrences(of: "{n}", with: "")
    }

    static func candidates(at date: Date, calendar: Calendar) -> [String] {
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date) // 1 = 日曜
        var list: [String]

        switch hour {
        case 0..<4:
            list = [
                "夜ふかしですか、{n}？",
                "まだ起きてたんですね、{n}",
                "{n}、そろそろ寝ませんか？",
                "静かな夜ですね、{n}",
                "夜更けですね、{n}",
                "眠れないんですか、{n}？",
                "{n}、あったかくしてくださいね",
            ]
        case 4..<7:
            list = [
                "早起きですね、{n}",
                "おはようございます、{n}",
                "{n}、朝が早いですね",
                "まだ街が静かですね、{n}",
                "いい朝になりそうですね、{n}",
                "{n}、もしかして寝てません？",
            ]
        case 7..<11:
            list = [
                "おはよう、{n}",
                "おはようございます、{n}",
                "{n}、朝ごはん食べました？",
                "よく眠れましたか、{n}？",
                "今日もよろしくです、{n}",
                "調子はどうですか、{n}？",
            ]
        case 11..<14:
            list = [
                "こんにちは、{n}",
                "お昼ですね、{n}",
                "{n}、お昼ごはんは何にします？",
                "調子はどうですか、{n}？",
                "午前中おつかれさまです、{n}",
            ]
        case 14..<18:
            list = [
                "こんにちは、{n}",
                "{n}、ひと休みしませんか？",
                "午後もがんばりましょう、{n}",
                "おやつの時間ですね、{n}",
                "調子はどうですか、{n}？",
                "眠くなる時間ですね、{n}",
            ]
        case 18..<22:
            list = [
                "こんばんは、{n}",
                "おつかれさまです、{n}",
                "おかえりなさい、{n}",
                "{n}、今日はどんな一日でした？",
                "ゆっくりしていってください、{n}",
                "{n}、晩ごはんは食べました？",
            ]
        default: // 22..<24
            list = [
                "こんばんは、{n}",
                "夜ふかしですか、{n}？",
                "{n}、今日もおつかれさまでした",
                "そろそろ休みませんか、{n}？",
                "夜はこれからですか、{n}？",
            ]
        }

        // いつでも出るもの
        list += [
            "ようこそ、{n}",
            "{n}、何から始めます？",
        ]

        // 曜日の特別版
        switch (weekday, hour) {
        case (2, 4..<12):
            list += ["月曜日ですね、{n}", "{n}、今週もぼちぼちいきましょう"]
        case (6, 17..<24):
            list += ["金曜の夜ですね、{n}", "{n}、今週もおつかれさまでした"]
        case (7, 6..<18), (1, 6..<18):
            list += ["いい週末を、{n}", "{n}、今日はお休みですか？"]
        case (1, 18..<24):
            list += ["{n}、明日からまた一週間ですね"]
        default:
            break
        }

        return list
    }
}
