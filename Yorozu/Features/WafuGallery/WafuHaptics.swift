import SwiftUI
import UIKit

/// 和風見本帳の触覚フィードバック。
/// 見本の各ファイルは、状態を変える @State に didSet でこれを呼び、
/// Toggle / Picker / Slider には `$x.wafuHaptic()` を渡している。
enum WafuHaptics {
    enum Kind { case tap, select, soft }

    /// 見本のコードはどれも main スレッドから呼ぶ。並行性チェックに引っかからないよう assumeIsolated で包む
    static func play(_ kind: Kind) {
        MainActor.assumeIsolated { playOnMain(kind) }
    }

    @MainActor
    private static func playOnMain(_ kind: Kind) {
        switch kind {
        case .tap:
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.impactOccurred(intensity: 0.8)
        case .soft:
            let g = UIImpactFeedbackGenerator(style: .soft)
            g.impactOccurred()
        case .select:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    static func tap() { play(.tap) }
    static func select() { play(.select) }
    static func soft() { play(.soft) }
}

extension Binding {
    /// 値が変わったときだけ触覚を鳴らす Binding
    func wafuHaptic(_ kind: WafuHaptics.Kind = .select) -> Binding<Value> where Value: Equatable {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                let changed = newValue != wrappedValue
                wrappedValue = newValue
                if changed { WafuHaptics.play(kind) }
            }
        )
    }
}
