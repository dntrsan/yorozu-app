import SwiftUI
import UIKit

/// 入力欄以外のどこかをタップしたらキーボードを下げる(アプリ全体に効く)。
/// ボタンなど他の操作は邪魔しない(タッチを横取りしない)。
struct KeyboardDismissOnTap: UIViewRepresentable {
    func makeUIView(context: Context) -> InstallerView { InstallerView() }
    func updateUIView(_ uiView: InstallerView, context: Context) {}

    final class InstallerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window,
                  !(window.gestureRecognizers ?? []).contains(where: { $0 is DismissKeyboardTapRecognizer })
            else { return }
            window.addGestureRecognizer(DismissKeyboardTapRecognizer())
        }
    }
}

final class DismissKeyboardTapRecognizer: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    init() {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap))
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        delegate = self
    }

    @objc private func handleTap() {
        view?.endEditing(true)
    }

    /// 入力欄そのもの(とその中身)をタップした時は反応しない
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var v = touch.view
        while let current = v {
            if current is UITextView || current is UITextField || current is UISearchBar { return false }
            v = current.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }
}
