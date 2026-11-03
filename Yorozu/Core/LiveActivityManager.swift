import ActivityKit
import Foundation

/// 常駐モード(ダイナミックアイランド)の管理。更新は1秒に1回までに間引く。
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    typealias State = YorozuActivityAttributes.ContentState

    private(set) var state = State()
    private var activity: Activity<YorozuActivityAttributes>?
    private var lastPush = Date.distantPast
    private var pending: Task<Void, Never>?

    private init() {}

    var isEnabled: Bool { UserDefaults.standard.bool(forKey: Prefs.islandEnabled) }

    var isSystemAllowed: Bool { ActivityAuthorizationInfo().areActivitiesEnabled }

    func setEnabled(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: Prefs.islandEnabled)
        if on { ensureRunning() } else { endAll() }
    }

    /// 有効なのに表示が消えていたら(8時間の上限や、ロック画面でスワイプされた等)出し直す。
    /// Activity.request はアプリが前面にいる時しか通らないので、前面に来るたびに呼ぶ。
    func ensureRunning() {
        guard isEnabled, isSystemAllowed else { return }
        if let a = activity, a.activityState == .active { push(); return }
        if let existing = Activity<YorozuActivityAttributes>.activities.first(where: { $0.activityState == .active }) {
            activity = existing
            push()
            return
        }
        do {
            activity = try Activity.request(
                attributes: YorozuActivityAttributes(),
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    func endAll() {
        pending?.cancel()
        pending = nil
        activity = nil
        let final = state
        Task {
            for a in Activity<YorozuActivityAttributes>.activities {
                await a.end(ActivityContent(state: final, staleDate: nil), dismissalPolicy: .immediate)
            }
        }
    }

    func update(force: Bool = false, _ mutate: (inout State) -> Void) {
        var next = state
        mutate(&next)
        guard next != state else { return }
        state = next
        guard isEnabled, activity != nil else { return }

        let elapsed = Date().timeIntervalSince(lastPush)
        if force || elapsed >= 1.0 {
            pending?.cancel()
            pending = nil
            push()
        } else if pending == nil {
            let wait = 1.0 - elapsed
            pending = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                guard !Task.isCancelled else { return }
                self?.pending = nil
                self?.push()
            }
        }
    }

    private func push() {
        guard let a = activity else { return }
        lastPush = Date()
        let s = state
        Task { await a.update(ActivityContent(state: s, staleDate: nil)) }
    }
}
