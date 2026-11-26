import PhotosUI
import SwiftUI

/// 角丸正方形のアイコン（丸ではなく、X の認証済み組織アカウントのような形）。
/// 写真が無ければ、名前の頭文字か人のマークを藍のグラデーションに載せる。
struct ProfileAvatar: View {
    var profile: ProfileStore = .shared
    var size: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
    }

    var body: some View {
        Group {
            if let icon = profile.icon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [Color(red: 0.16, green: 0.29, blue: 0.52),
                                            Color(red: 0.07, green: 0.13, blue: 0.27)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    if let initial = profile.displayName?.first {
                        Text(String(initial))
                            .font(.system(size: size * 0.44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.42, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(shape)
        .overlay(shape.strokeBorder(.primary.opacity(0.08), lineWidth: 1))
        .accessibilityLabel("アイコン")
    }
}

/// アイコンを選ぶボタン。押すと写真ライブラリが開き、選んだらすぐ保存する。
/// 長押しのメニューから外すこともできる。
struct ProfileIconPicker: View {
    @Bindable var profile: ProfileStore = .shared
    var size: CGFloat
    @State private var item: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $item, matching: .images) {
            ProfileAvatar(profile: profile, size: size)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: profile.icon == nil ? "plus" : "pencil")
                        .font(.system(size: max(10, size * 0.16), weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: max(20, size * 0.3), height: max(20, size * 0.3))
                        .background(Color.accentColor, in: Circle())
                        .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 2))
                        .offset(x: size * 0.06, y: size * 0.06)
                }
        }
        .buttonStyle(.plain)
        .contextMenu {
            if profile.icon != nil {
                Button("アイコンを外す", systemImage: "trash", role: .destructive) {
                    profile.removeIcon()
                }
            }
        }
        .onChange(of: item) {
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    profile.setIcon(from: data)
                }
                self.item = nil
            }
        }
    }
}

/// 初回起動時の「はじめまして」。どちらも任意で、何も入れずに進んでもいい。
struct OnboardingView: View {
    @Bindable var profile: ProfileStore = .shared
    var onDone: () -> Void
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)
            VStack(spacing: 10) {
                Text("はじめまして")
                    .font(.largeTitle.bold())
                Text("ホームで呼ぶ名前とアイコンを決められます。\nどちらも任意で、あとから設定で変えられます。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ProfileIconPicker(profile: profile, size: 112)

            VStack(alignment: .leading, spacing: 6) {
                Text("呼び方").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                TextField("たとえば ゆうき", text: $profile.name)
                    .textContentType(.nickname)
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .onSubmit { onDone() }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text("この端末の中にだけ保存します。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onDone()
                } label: {
                    Text(profile.displayName == nil ? "このままはじめる" : "はじめる")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .glassButtonStyle(prominent: true)

                Text("よろず — made by \(AppCredit.author)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture { nameFocused = false }
    }
}

/// 作った人の表記
enum AppCredit {
    static let author = "dntrsan"
}
