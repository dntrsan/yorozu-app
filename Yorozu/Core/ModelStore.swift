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

    private var downloaders: [String: Downloader] = [:]
    private let selectedKey = "selectedModelFilename"

    private init() {
        selectedFilename = UserDefaults.standard.string(forKey: selectedKey) ?? ""
        refresh()
    }

    static var documentsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var modelsDir: URL {
        let dir = documentsDir.appendingPathComponent("Models", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

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
        guard downloaders[filename] == nil else { return }
        downloadError = nil
        downloadProgress[filename] = 0
        let dest = Self.modelsDir.appendingPathComponent(filename)
        let d = Downloader(destination: dest) { [weak self] p in
            Task { @MainActor in self?.downloadProgress[filename] = p }
        }
        downloaders[filename] = d
        Task {
            do {
                try await d.start(url: url)
                var u = dest
                var rv = URLResourceValues()
                rv.isExcludedFromBackup = true
                try? u.setResourceValues(rv)
                refresh()
                if selectedFilename.isEmpty || selectedURL == nil { select(filename) }
            } catch {
                if (error as? URLError)?.code != .cancelled {
                    downloadError = "\(filename): \(error.localizedDescription)"
                }
            }
            downloaders[filename] = nil
            downloadProgress[filename] = nil
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
        downloaders[filename]?.cancel()
    }
}

/// 進捗付きダウンロード(フォアグラウンド用)
final class Downloader: NSObject, URLSessionDownloadDelegate {
    private let destination: URL
    private let onProgress: (Double) -> Void
    private var continuation: CheckedContinuation<Void, Error>?
    private var session: URLSession?
    private var task: URLSessionDownloadTask?

    init(destination: URL, onProgress: @escaping (Double) -> Void) {
        self.destination = destination
        self.onProgress = onProgress
    }

    func start(url: URL) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            continuation = cont
            let s = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            session = s
            let t = s.downloadTask(with: url)
            task = t
            t.resume()
        }
    }

    func cancel() { task?.cancel() }

    private func finish(_ result: Result<Void, Error>) {
        guard let c = continuation else { return }
        continuation = nil
        session?.finishTasksAndInvalidate()
        session = nil
        c.resume(with: result)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        onProgress(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let http = downloadTask.response as? HTTPURLResponse, http.statusCode != 200 {
            finish(.failure(NSError(domain: "Yorozu", code: http.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)(URLが違うか、ログイン必須のモデルかも)"])))
            return
        }
        do {
            let fm = FileManager.default
            try? fm.removeItem(at: destination)
            try fm.moveItem(at: location, to: destination)
            finish(.success(()))
        } catch {
            finish(.failure(error))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error { finish(.failure(error)) }
    }
}
