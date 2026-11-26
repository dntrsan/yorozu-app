import SwiftUI
import UIKit

/// ユーザーの呼び方とアイコン。どちらも任意で、端末の中（このアプリの中）にだけ保存する。
/// 名前は UserDefaults、アイコンは Application Support の JPEG
/// （Documents だとファイルApp に見えてしまうので避ける）。
@Observable
@MainActor
final class ProfileStore {
    static let shared = ProfileStore()

    private enum Key {
        static let name = "profile.name"
        static let onboarded = "profile.onboarded"
    }

    var name: String {
        didSet { UserDefaults.standard.set(name, forKey: Key.name) }
    }

    /// 初回の「はじめまして」画面を出したか
    var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: Key.onboarded) }
    }

    private(set) var icon: UIImage?

    /// 空白だけなら名前なしとして扱う
    var displayName: String? {
        let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    private init() {
        name = UserDefaults.standard.string(forKey: Key.name) ?? ""
        hasOnboarded = UserDefaults.standard.bool(forKey: Key.onboarded)
        icon = (try? Data(contentsOf: Self.iconURL)).flatMap(UIImage.init(data:))
    }

    /// 切り抜き前の元写真（「切り抜きを直す」用）。向きを直し、長辺 2048px までに縮めたもの
    var original: UIImage? {
        (try? Data(contentsOf: Self.originalURL)).flatMap(UIImage.init(data:))
    }

    /// 写真ライブラリのデータを、向きを直して扱いやすい大きさの UIImage にする
    nonisolated static func normalized(from data: Data, maxSide: CGFloat = 2048) -> UIImage? {
        guard let source = UIImage(data: data) else { return nil }
        let s = source.size
        let k = min(1, maxSide / max(s.width, s.height))
        let size = CGSize(width: (s.width * k).rounded(), height: (s.height * k).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            source.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// 切り抜いた正方形を 512px の JPEG で保存する。元写真も一緒に残す
    @discardableResult
    func setIcon(cropped: UIImage, original: UIImage?) -> Bool {
        guard let jpeg = cropped.jpegData(compressionQuality: 0.88) else { return false }
        do {
            try FileManager.default.createDirectory(at: Self.iconURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try jpeg.write(to: Self.iconURL, options: .atomic)
            if let original, let o = original.jpegData(compressionQuality: 0.85) {
                try o.write(to: Self.originalURL, options: .atomic)
            }
            icon = cropped
            return true
        } catch {
            return false
        }
    }

    func removeIcon() {
        try? FileManager.default.removeItem(at: Self.iconURL)
        try? FileManager.default.removeItem(at: Self.originalURL)
        icon = nil
    }

    private static var originalURL: URL {
        iconURL.deletingLastPathComponent().appendingPathComponent("original.jpg")
    }

    private static var iconURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Profile", isDirectory: true)
            .appendingPathComponent("icon.jpg")
    }
}
