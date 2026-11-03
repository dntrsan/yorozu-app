import Foundation

/// バックグラウンド URLSession でのダウンロード。
/// ホームに戻る/画面ロック/アプリがiOSに終了されても続く(ユーザーが上スワイプで強制終了した時だけ止まる)。
/// 回線が切れた時は途中データを保存して、次は続きから再開する。
final class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = BackgroundDownloader()
    static let identifier = "dev.yorozu.app.model-download"

    /// (ファイル名, 進捗0...1)
    var onProgress: ((String, Double) -> Void)?
    /// (ファイル名, 結果)
    var onFinish: ((String, Result<URL, Error>) -> Void)?
    /// AppDelegate から渡される。全イベント処理後に呼ぶ必要がある
    var backgroundCompletionHandler: (() -> Void)?

    private let lock = NSLock()
    private var reported = Set<Int>()
    /// 進捗通知の間引き用(ファイル名 → 最後に知らせた時刻と値)
    private var lastProgress: [String: (time: CFAbsoluteTime, value: Double)] = [:]

    lazy var session: URLSession = {
        let c = URLSessionConfiguration.background(withIdentifier: Self.identifier)
        c.isDiscretionary = false
        c.sessionSendsLaunchEvents = true
        c.allowsCellularAccess = true
        c.allowsExpensiveNetworkAccess = true
        c.allowsConstrainedNetworkAccess = true
        return URLSession(configuration: c, delegate: self, delegateQueue: nil)
    }()

    static var modelsDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Models", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static var resumeDir: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("DownloadResume", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func resumeURL(_ filename: String) -> URL {
        Self.resumeDir.appendingPathComponent(filename + ".resume")
    }

    // MARK: - API

    func start(url: URL, filename: String) {
        let task: URLSessionDownloadTask
        if let data = try? Data(contentsOf: resumeURL(filename)) {
            task = session.downloadTask(withResumeData: data)
        } else {
            task = session.downloadTask(with: url)
        }
        try? FileManager.default.removeItem(at: resumeURL(filename))
        task.taskDescription = filename
        task.resume()
    }

    func cancel(filename: String) {
        session.getAllTasks { tasks in
            tasks.filter { $0.taskDescription == filename }.forEach { $0.cancel() }
        }
        try? FileManager.default.removeItem(at: resumeURL(filename))
    }

    func hasResumeData(for filename: String) -> Bool {
        FileManager.default.fileExists(atPath: resumeURL(filename).path)
    }

    /// 起動時に、裏で走り続けていたダウンロードを拾い直す
    func runningDownloads(_ completion: @escaping ([String: Double]) -> Void) {
        session.getAllTasks { tasks in
            var result: [String: Double] = [:]
            for t in tasks where t.state == .running || t.state == .suspended {
                guard let name = t.taskDescription else { continue }
                let total = t.countOfBytesExpectedToReceive
                result[name] = total > 0 ? Double(t.countOfBytesReceived) / Double(total) : 0
            }
            completion(result)
        }
    }

    // MARK: - Delegate

    private func markReported(_ task: URLSessionTask) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return reported.insert(task.taskIdentifier).inserted
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let name = downloadTask.taskDescription, totalBytesExpectedToWrite > 0 else { return }
        let value = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        // iOS は数十KBごと(速い回線だと毎秒数百回)に呼んでくる。そのまま画面に流すと
        // メインスレッドが埋まって入力までカクつくので、0.3秒に1回までに間引く
        let now = CFAbsoluteTimeGetCurrent()
        lock.lock()
        let last = lastProgress[name]
        let shouldReport = last == nil || now - last!.time >= 0.3 || value >= 1
        if shouldReport { lastProgress[name] = (now, value) }
        lock.unlock()
        guard shouldReport else { return }
        onProgress?(name, value)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let name = downloadTask.taskDescription else { return }
        guard markReported(downloadTask) else { return }

        if let http = downloadTask.response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let err = NSError(domain: "Yorozu", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(http.statusCode)(URLが違うか、ログイン必須のモデルかも)"
            ])
            onFinish?(name, .failure(err))
            return
        }
        // location はこのメソッドを抜けると消えるので、ここで同期的に移す
        let dest = Self.modelsDir.appendingPathComponent(name)
        do {
            let fm = FileManager.default
            try? fm.removeItem(at: dest)
            try fm.moveItem(at: location, to: dest)
            var u = dest
            var rv = URLResourceValues()
            rv.isExcludedFromBackup = true
            try? u.setResourceValues(rv)
            onFinish?(name, .success(dest))
        } catch {
            onFinish?(name, .failure(error))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error, let name = task.taskDescription else { return }
        let ns = error as NSError
        if let data = ns.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            try? data.write(to: resumeURL(name))
        }
        guard markReported(task) else { return }
        onFinish?(name, .failure(error))
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
