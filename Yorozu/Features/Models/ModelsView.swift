import SwiftUI

struct ModelsView: View {
    var store: ModelStore
    @State private var customURL = ""

    var body: some View {
        NavigationStack {
            List {
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

    @ViewBuilder
    private func catalogRow(_ c: CatalogModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(c.title).font(.subheadline.bold())
            Text(c.note).font(.caption).foregroundStyle(.secondary)
            if let p = store.downloadProgress[c.filename] {
                HStack {
                    ProgressView(value: p)
                    Text("\(Int(p * 100))%").font(.caption.monospacedDigit())
                    Button("中止") { store.cancelDownload(c.filename) }.font(.caption)
                }
            } else if store.isDownloaded(c.filename) {
                Label("ダウンロード済み", systemImage: "checkmark").font(.caption).foregroundStyle(.green)
            } else {
                Button("ダウンロード") { store.download(url: c.url, filename: c.filename) }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
}
