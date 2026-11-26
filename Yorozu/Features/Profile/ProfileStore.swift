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

    /// 選んだ写真を真ん中で正方形に切り抜き、512px の JPEG にして保存する
    @discardableResult
    func setIcon(from data: Data) -> Bool {
        guard let source = UIImage(data: data) else { return false }
        let side: CGFloat = 512
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let squared = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            let s = source.size
            let scale = max(side / s.width, side / s.height)
            let w = s.width * scale, h = s.height * scale
            source.draw(in: CGRect(x: (side - w) / 2, y: (side - h) / 2, width: w, height: h))
        }
        guard let jpeg = squared.jpegData(compressionQuality: 0.85) else { return false }
        do {
            try FileManager.default.createDirectory(at: Self.iconURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try jpeg.write(to: Self.iconURL, options: .atomic)
            icon = squared
            return true
        } catch {
            return false
        }
    }

    func removeIcon() {
        try? FileManager.default.removeItem(at: Self.iconURL)
        icon = nil
    }

    private static var iconURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Profile", isDirectory: true)
            .appendingPathComponent("icon.jpg")
    }
}
