import ActivityKit
import SwiftUI
import WidgetKit

@main
struct YorozuWidgetBundle: WidgetBundle {
    var body: some Widget {
        YorozuLiveActivity()
    }
}

struct YorozuLiveActivity: Widget {
    typealias State = YorozuActivityAttributes.ContentState

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: YorozuActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .padding(16)
                .activitySystemActionForegroundColor(.primary)
                .widgetURL(URL(string: "yorozu://chat"))
        } dynamicIsland: { context in
            let s = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("よろず").font(.headline)
                    } icon: {
                        Image(systemName: s.symbol).foregroundStyle(phaseTint(s))
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(s.statusText)
                        .font(.caption)
                        .foregroundStyle(phaseTint(s))
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    if !s.modelName.isEmpty {
                        Text(s.shortModelName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        if !s.snippet.isEmpty {
                            Text(s.snippet)
                                .font(.footnote)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if let p = s.downloadProgress {
                            DownloadRow(name: s.downloadName ?? "", progress: p)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: s.downloadProgress != nil && s.engine != .generating
                      ? "arrow.down.circle.fill" : s.symbol)
                    .foregroundStyle(phaseTint(s))
            } compactTrailing: {
                CompactTrailing(state: s)
            } minimal: {
                if let p = s.downloadProgress, s.engine != .generating {
                    ProgressView(value: p).progressViewStyle(.circular).tint(.blue)
                } else {
                    Image(systemName: s.symbol).foregroundStyle(phaseTint(s))
                }
            }
            .widgetURL(URL(string: s.downloadProgress != nil ? "yorozu://models" : "yorozu://chat"))
            .keylineTint(phaseTint(s))
        }
    }
}

private func phaseTint(_ s: YorozuActivityAttributes.ContentState) -> Color {
    switch s.engine {
    case .generating: return .purple
    case .ready: return .green
    case .loading: return .blue
    case .error: return .red
    case .noModel: return .orange
    }
}

private struct CompactTrailing: View {
    let state: YorozuActivityAttributes.ContentState

    var body: some View {
        if state.engine == .generating {
            Image(systemName: "ellipsis").symbolEffect(.pulse)
                .foregroundStyle(.purple)
        } else if let p = state.downloadProgress {
            Text("\(Int(p * 100))%").font(.caption2.monospacedDigit())
        } else {
            Text(state.statusText).font(.caption2)
        }
    }
}

private struct DownloadRow: View {
    let name: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "arrow.down.circle")
                Text(name.replacingOccurrences(of: ".gguf", with: "")).lineLimit(1)
                Spacer()
                Text("\(Int(progress * 100))%").monospacedDigit()
            }
            .font(.caption2)
            ProgressView(value: progress).tint(.blue)
        }
    }
}

private struct LockScreenView: View {
    let state: YorozuActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: state.symbol).foregroundStyle(phaseTint(state))
                Text("よろず").font(.headline)
                Spacer()
                Text(state.statusText).font(.caption).foregroundStyle(phaseTint(state))
            }
            if !state.modelName.isEmpty {
                Text(state.shortModelName).font(.caption2).foregroundStyle(.secondary)
            }
            if !state.snippet.isEmpty {
                Text(state.snippet).font(.footnote).lineLimit(3)
            }
            if let p = state.downloadProgress {
                DownloadRow(name: state.downloadName ?? "", progress: p)
            }
        }
    }
}
