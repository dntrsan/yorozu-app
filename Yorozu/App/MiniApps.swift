import SwiftUI

enum HomeRoute: Hashable {
    case history
}

/// ホームに並ぶ「よろず内のアプリ」。新しい機能を作ったらここに1行足す。
struct MiniApp: Identifiable {
    enum Destination {
        case tab(AppTab)      // 下のタブに切り替える
        case route(HomeRoute) // ホームから画面を開く
    }

    let id: String
    let title: String
    let symbol: String
    let color: Color
    let destination: Destination

    static let all: [MiniApp] = [
        MiniApp(id: "chat", title: "チャット", symbol: "bubble.left.and.bubble.right.fill", color: .purple, destination: .tab(.chat)),
        MiniApp(id: "history", title: "会話履歴", symbol: "clock.arrow.circlepath", color: .indigo, destination: .route(.history)),
        MiniApp(id: "models", title: "モデル", symbol: "externaldrive.fill", color: .blue, destination: .tab(.models)),
        MiniApp(id: "settings", title: "設定", symbol: "gearshape.fill", color: .gray, destination: .tab(.settings)),
    ]
}
