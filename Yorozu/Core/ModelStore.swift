import Foundation
import Observation

struct CatalogModel: Identifiable, Hashable {
    let filename: String
    let title: String
    let note: String
    let url: URL
    var id: String { filename }
}

struct LocalModel: Identifiable, Hashable {
    let url: URL
    let sizeBytes: Int64
    var id: String { url.lastPathComponent }
    var filename: String { url.lastPathComponent }
}

enum Catalog {
    // ※ リポジトリ名/ファイル名は 404 になることがある。その時は「URLを指定して追加」を使うか、
    //    ファイルApp経由で GGUF を置けばOK。
    static let models: [CatalogModel] = [
        CatalogModel(
            filename: "Qwen3-4B-Instruct-2507-Q4_K_M.gguf",
            title: "Qwen3 4B Instruct 2507 (標準・動作確認用)",
            note: "約2.5GB。検閲あり。まずパイプラインが動くかの確認用。",
            url: URL(string: "https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf")!
        ),
        CatalogModel(
            filename: "Huihui-Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf",
            title: "Qwen3 4B Instruct 2507 abliterated (無検閲)",
            note: "約2.5GB。検閲除去版。日本語は標準版よりやや劣る場合あり。",
            url: URL(string: "https://huggingface.co/mradermacher/Huihui-Qwen3-4B-Instruct-2507-abliterated-GGUF/resolve/main/Huihui-Qwen3-4B-Instruct-2507-abliterated.Q4_K_M.gguf")!
        ),
    ]
}

@Observable
@MainActor
final class ModelStore {
    static let shared = ModelStore()

    var localModels: [LocalModel] = []
    var downloadProgress: [String: Double] = [:]
    var downloadError: String?
    private(set) var selectedFilename: String

    private let selectedKey = "selectedModelFilename"

    private init() {
        selectedFilename = UserDefaults.standard.string(forKey: selectedKey) ?? ""
        refresh()

        // コールバックは session を作る前に繋ぐ(裏で完了したイベントを取りこぼさないため)
        let dl = BackgroundDownloader.shared
        dl.onProgress = { name, p in
            Task { @MainActor in ModelStore.shared.handleProgress(name, p) }
        }
        dl.onFinish = { name, result in
            Task { @MainActor in ModelStore.shared.handleFinish(name, result) }
        }
        dl.runningDownloads { running in
            Task { @MainActor in
                for (name, p) in running { ModelStore.shared.downloadProgress[name] = p }
            }
        }
    }

    static var documentsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var modelsDir: URL { BackgroundDownloader.modelsDir }

    var selectedURL: URL? {
        localModels.first(where: { $0.filename == selectedFilename })?.url
    }

    func select(_ filename: String) {
        selectedFilename = filename
        UserDefaults.standard.set(filename, forKey: selectedKey)
    }

    /// Documents 直下と Documents/Models の .gguf を列挙する(ファイルApp経由で置いたものも拾う)
    func refresh() {
        let fm = FileManager.default
        var found: [LocalModel] = []
        for dir in [Self.modelsDir, Self.documentsDir] {
            let items = (try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey])) ?? []
            for url in items where url.pathExtension.lowercased() == "gguf" {
                let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).flatMap { Int64($0) } ?? 0
                found.append(LocalModel(url: url, sizeBytes: size))
            }
        }
        localModels = found.sorted { $0.filename < $1.filename }
        if selectedURL == nil, let first = localModels.first, selectedFilename.isEmpty {
            select(first.filename)
        }
    }

    func isDownloaded(_ filename: String) -> Bool {
        localModels.contains { $0.filename == filename }
    }

    func delete(_ model: LocalModel) {
        try? FileManager.default.removeItem(at: model.url)
        if selectedFilename == model.filename { select("") }
        refresh()
    }

    // MARK: - Download

    func download(url: URL, filename: String) {
        guard downloadProgress[filename] == nil else { return }
        downloadError = nil
        downloadProgress[filename] = 0
        BackgroundDownloader.shared.start(url: url, filename: filename)
        LiveActivityManager.shared.update(force: true) {
            $0.downloadName = filename
            $0.downloadProgress = 0
        }
    }

    func canResume(_ filename: String) -> Bool {
        BackgroundDownloader.shared.hasResumeData(for: filename)
    }

    fileprivate func handleProgress(_ name: String, _ p: Double) {
        // 中止直後に遅れて届いた進捗で復活させない
        guard downloadProgress[name] != nil else { return }
        downloadProgress[name] = p
        LiveActivityManager.shared.update {
            $0.downloadName = name
            $0.downloadProgress = p
        }
    }

    fileprivate func handleFinish(_ name: String, _ result: Result<URL, Error>) {
        downloadProgress[name] = nil
        switch result {
        case .success:
            refresh()
            if selectedFilename.isEmpty || selectedURL == nil { select(name) }
        case .failure(let error):
            if (error as? URLError)?.code != .cancelled {
                let hint = canResume(name) ? "(もう一度押すと続きから再開するだ)" : ""
                downloadError = "\(name): \(error.localizedDescription)\(hint)"
            }
        }
        let next = downloadProgress.first
        LiveActivityManager.shared.update(force: true) {
            $0.downloadName = next?.key
            $0.downloadProgress = next?.value
        }
    }

    /// Hugging Face の blob URL を貼られても resolve URL に直す
    func downloadCustom(urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/blob/", with: "/resolve/")
        guard let url = URL(string: trimmed), url.lastPathComponent.lowercased().hasSuffix(".gguf") else {
            downloadError = ".gguf で終わるURLを入れてけろ"
            return
        }
        download(url: url, filename: url.lastPathComponent)
    }

    func cancelDownload(_ filename: String) {
        BackgroundDownloader.shared.cancel(filename: filename)
        handleFinish(filename, .failure(URLError(.cancelled)))
    }
}
