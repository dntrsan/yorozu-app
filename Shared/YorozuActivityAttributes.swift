import ActivityKit
import Foundation

/// ダイナミックアイランド/ロック画面に出す常駐表示のデータ(アプリとウィジェット拡張で共有)
struct YorozuActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        enum Engine: String, Codable, Hashable {
            case noModel, loading, ready, generating, error
        }

        var engine: Engine = .noModel
        var modelName: String = ""
        /// 直近の返答(の末尾)
        var snippet: String = ""
        var downloadName: String?
        var downloadProgress: Double?
    }

    var appName: String = "よろず"
}

extension YorozuActivityAttributes.ContentState {
    var shortModelName: String {
        let base = modelName.replacingOccurrences(of: ".gguf", with: "")
        return base.count > 28 ? String(base.prefix(28)) + "…" : base
    }

    var statusText: String {
        switch engine {
        case .noModel: return "モデル未選択"
        case .loading: return "読み込み中"
        case .ready: return "待機中"
        case .generating: return "生成中"
        case .error: return "エラー"
        }
    }

    var symbol: String {
        switch engine {
        case .noModel: return "tray"
        case .loading: return "hourglass"
        case .ready: return "sparkles"
        case .generating: return "ellipsis.bubble.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}
