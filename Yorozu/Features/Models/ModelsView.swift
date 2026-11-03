import SwiftUI
import os

struct ModelsView: View {
    var store: ModelStore
    @State private var customURL = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("端末のRAM", value: Self.gb(ProcessInfo.processInfo.physicalMemory))
                    LabeledContent("アプリが使える残り", value: Self.gb(UInt64(os_proc_available_memory())))
                } header: {
                    Text("メモリ")
                } footer: {
                    Text("4B Q4 モデルは約2.5GB。読み込み前の「使える残り」がそれより十分大きくないと落ちるだ。")
                }

                Section("入ってるモデル") {
                    if store.localModels.isEmpty {
                        Text("まだ無いだ").foregroundStyle(.secondary)
                    }
                    ForEach(store.localModels) { m in
                        Button {
                            store.select(m.filename)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(m.filename).font(.subheadline).lineLimit(2)
                                    Text(ByteCountFormatter.string(fromByteCount: m.sizeBytes, countStyle: .file))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if store.selectedFilename == m.filename {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                }
                            }
                        }
                        .tint(.primary)
                        .swipeActions {
                            Button("削除", role: .destructive) { store.delete(m) }
                        }
                    }
                }

                if !store.downloadProgress.isEmpty {
                    Section {
                        ForEach(store.downloadProgress.keys.sorted(), id: \.self) { name in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(name).font(.subheadline).lineLimit(2)
                                HStack {
                                    ProgressView(value: store.downloadProgress[name] ?? 0)
                                    Text("\(Int((store.downloadProgress[name] ?? 0) * 100))%")
                                        .font(.caption.monospacedDigit())
                                    Button("中止", role: .destructive) { store.cancelDownload(name) }
                                        .font(.caption)
                                }
                            }
                        }
                    } header: {
                        Text("ダウンロード中")
                    } footer: {
                        Text("ホームに戻ったり画面をロックしても続くだ。アプリを上にスワイプして完全に終了した時だけ止まるから、それだけは気をつけてけろ。")
                    }
                }

                Section("ダウンロード") {
                    ForEach(Catalog.models) { c in
                        catalogRow(c)
                    }
                }

                Section {
                    TextField("https://huggingface.co/.../xxx.gguf", text: $customURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    Button("このURLからダウンロード") {
                        store.downloadCustom(urlString: customURL)
                        customURL = ""
                    }
                    .disabled(customURL.isEmpty)
                } header: {
                    Text("URLを指定して追加")
                } footer: {
                    Text("ファイルApp →「このiPhone内」→「よろず」に .gguf を直接置いてもOK。置いたら下に引っ張って更新。")
                }

                if let err = store.downloadError {
                    Section { Text(err).foregroundStyle(.red).font(.footnote) }
                }
            }
            .navigationTitle("モデル")
            .refreshable { store.refresh() }
        }
    }

    private static func gb(_ bytes: UInt64) -> String {
        String(format: "%.1f GB", Double(bytes) / 1_073_741_824)
    }

    @ViewBuilder
    private func catalogRow(_ c: CatalogModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(c.title).font(.subheadline.bold())
            Text(c.note).font(.caption).foregroundStyle(.secondary)
            if store.downloadProgress[c.filename] != nil {
                Label("ダウンロード中…", systemImage: "arrow.down.circle").font(.caption).foregroundStyle(.secondary)
            } else if store.isDownloaded(c.filename) {
                Label("ダウンロード済み", systemImage: "checkmark").font(.caption).foregroundStyle(.green)
            } else {
                Button(store.canResume(c.filename) ? "続きから再開" : "ダウンロード") {
                    store.download(url: c.url, filename: c.filename)
                }
                .glassButtonStyle()
            }
        }
        .padding(.vertical, 4)
    }
}
