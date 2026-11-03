import SwiftUI
import UIKit

// LLM の返答向けの軽量マークダウン表示。
// 対応: 見出し / 段落 / 箇条書き・番号付き(入れ子) / コードブロック(コピー可) / 引用 / 区切り線 / 表
// 文中の **太字** *斜体* `コード` ~~取り消し~~ [リンク](url) は AttributedString に任せる。
// 生成途中(コードブロックが閉じてない等)でも崩れないようにしてある。

enum MDBlock: Hashable {
    struct ListItem: Hashable {
        var indent: Int
        var marker: String   // "•" か "1." など
        var text: String
    }

    case heading(level: Int, text: String)
    case paragraph(String)
    case list([ListItem])
    case code(lang: String, text: String)
    case quote(String)
    case rule
    case table([[String]])
}

enum MarkdownParser {
    static func parse(_ source: String) -> [MDBlock] {
        var blocks: [MDBlock] = []
        var paragraph: [String] = []
        var listItems: [MDBlock.ListItem] = []
        var quote: [String] = []
        var table: [[String]] = []
        var codeLang: String?
        var codeLines: [String] = []

        func flushParagraph() {
            if !paragraph.isEmpty { blocks.append(.paragraph(paragraph.joined(separator: "\n"))); paragraph = [] }
        }
        func flushList() {
            if !listItems.isEmpty { blocks.append(.list(listItems)); listItems = [] }
        }
        func flushQuote() {
            if !quote.isEmpty { blocks.append(.quote(quote.joined(separator: "\n"))); quote = [] }
        }
        func flushTable() {
            if !table.isEmpty { blocks.append(.table(table)); table = [] }
        }
        func flushAll() { flushParagraph(); flushList(); flushQuote(); flushTable() }

        for rawLine in source.components(separatedBy: "\n") {
            let line = rawLine.replacingOccurrences(of: "\t", with: "    ")
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // コードブロックの中
            if let lang = codeLang {
                if trimmed.hasPrefix("```") {
                    blocks.append(.code(lang: lang, text: codeLines.joined(separator: "\n")))
                    codeLang = nil
                    codeLines = []
                } else {
                    codeLines.append(rawLine)
                }
                continue
            }

            if trimmed.hasPrefix("```") {
                flushAll()
                codeLang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                continue
            }

            if trimmed.isEmpty {
                flushAll()
                continue
            }

            // 表(| a | b |)
            if trimmed.hasPrefix("|"), trimmed.dropFirst().contains("|") {
                flushParagraph(); flushList(); flushQuote()
                let cells = splitRow(trimmed)
                if !isSeparatorRow(cells) { table.append(cells) }
                continue
            } else {
                flushTable()
            }

            // 見出し
            if trimmed.hasPrefix("#") {
                let hashes = trimmed.prefix { $0 == "#" }.count
                let rest = trimmed.dropFirst(hashes)
                if hashes <= 6, rest.first == " " {
                    flushAll()
                    blocks.append(.heading(level: hashes, text: rest.trimmingCharacters(in: .whitespaces)))
                    continue
                }
            }

            // 区切り線
            if trimmed.count >= 3, let c = trimmed.first, "-*_".contains(c),
               trimmed.allSatisfy({ $0 == c || $0 == " " }) {
                flushAll()
                blocks.append(.rule)
                continue
            }

            // 引用
            if trimmed.hasPrefix(">") {
                flushParagraph(); flushList()
                quote.append(String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces))
                continue
            } else {
                flushQuote()
            }

            // 箇条書き / 番号付き
            if let item = listItem(line) {
                flushParagraph()
                listItems.append(item)
                continue
            }
            // 箇条書きの続きの行
            if !listItems.isEmpty, line.hasPrefix("  ") {
                listItems[listItems.count - 1].text += "\n" + trimmed
                continue
            }
            flushList()

            paragraph.append(line)
        }

        if let lang = codeLang {
            // 生成途中で閉じてないコードブロック
            blocks.append(.code(lang: lang, text: codeLines.joined(separator: "\n")))
        }
        flushAll()
        return blocks
    }

    private static func listItem(_ line: String) -> MDBlock.ListItem? {
        let spaces = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(spaces)
        let indent = spaces / 2
        if let first = rest.first, "-*+・".contains(first) {
            let after = rest.dropFirst()
            if after.first == " " {
                return .init(indent: indent, marker: "•", text: after.trimmingCharacters(in: .whitespaces))
            }
        }
        let digits = rest.prefix { $0.isNumber }
        if !digits.isEmpty, digits.count <= 3 {
            let after = rest.dropFirst(digits.count)
            if let p = after.first, p == "." || p == ")", after.dropFirst().first == " " {
                return .init(indent: indent, marker: "\(digits).", text: after.dropFirst().trimmingCharacters(in: .whitespaces))
            }
        }
        return nil
    }

    private static func splitRow(_ row: String) -> [String] {
        var s = row
        if s.hasPrefix("|") { s.removeFirst() }
        if s.hasSuffix("|") { s.removeLast() }
        return s.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private static func isSeparatorRow(_ cells: [String]) -> Bool {
        !cells.isEmpty && cells.allSatisfy { c in
            !c.isEmpty && c.allSatisfy { $0 == "-" || $0 == ":" || $0 == " " }
        }
    }

    /// 文中の装飾(太字・コード・リンクなど)
    static func inline(_ text: String) -> AttributedString {
        let opts = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace,
                                                           failurePolicy: .returnPartiallyParsedIfPossible)
        return (try? AttributedString(markdown: text, options: opts)) ?? AttributedString(text)
    }
}

struct MarkdownView: View {
    let source: String

    var body: some View {
        let blocks = MarkdownParser.parse(source)
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                MDBlockView(block: block)
            }
        }
    }
}

private struct MDBlockView: View {
    let block: MDBlock

    var body: some View {
        switch block {
        case .heading(let level, let text):
            Text(MarkdownParser.inline(text))
                .font(level == 1 ? .title3.bold() : level == 2 ? .headline : .subheadline.bold())
                .padding(.top, 2)

        case .paragraph(let text):
            Text(MarkdownParser.inline(text))

        case .list(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(item.marker)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Text(MarkdownParser.inline(item.text))
                    }
                    .padding(.leading, CGFloat(item.indent) * 16)
                }
            }

        case .code(let lang, let text):
            CodeBlockView(lang: lang, code: text)

        case .quote(let text):
            HStack(alignment: .top, spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 3)
                Text(MarkdownParser.inline(text))
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)

        case .rule:
            Divider()

        case .table(let rows):
            TableBlockView(rows: rows)
        }
    }
}

private struct CodeBlockView: View {
    let lang: String
    let code: String
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(lang.isEmpty ? "code" : lang)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    copied = true
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        copied = false
                    }
                } label: {
                    Label(copied ? "コピーしただ" : "コピー", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
        }
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct TableBlockView: View {
    let rows: [[String]]

    var body: some View {
        let columns = rows.map(\.count).max() ?? 0
        ScrollView(.horizontal, showsIndicators: false) {
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                    GridRow {
                        ForEach(0..<columns, id: \.self) { c in
                            Text(MarkdownParser.inline(c < row.count ? row[c] : ""))
                                .font(i == 0 ? .footnote.bold() : .footnote)
                        }
                    }
                    if i == 0 { Divider() }
                }
            }
            .padding(10)
        }
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
