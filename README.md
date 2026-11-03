# Yorozu(よろず)

iPhone の中だけで動く、ローカルLLMチャット。将来いろんな機能を詰め込む「万屋」アプリの土台。

- 推論: llama.cpp(公式 xcframework, Metal)
- UI: SwiftUI (iOS 17+)
- ビルド: GitHub Actions で未署名IPA → Sideloadly で入れる

## 使い方

1. このリポジトリを GitHub に push(`main`)
2. Actions の **Build iOS (unsigned IPA)** が走る(手動実行も可)
3. Artifacts の `Yorozu-ipa` をダウンロード → zip を展開 → `Yorozu.ipa`
4. Sideloadly で iPhone に入れる
5. アプリの「モデル」タブでモデルをダウンロード(約2.5GB、Wi-Fi推奨)

## バージョン

- 表示バージョン: `project.yml` の `MARKETING_VERSION`(機能を変えたら上げる)
- ビルド番号: GitHub Actions の実行番号(自動で増える)
- IPA名: `Yorozu-v<バージョン>-build<番号>.ipa`、アプリ内は「設定 → このアプリについて」

## Googleドライブへの自動アップロード

ビルドが通ると、IPA が Googleドライブの `yorozu-iosapp` フォルダに入る。
初回だけ、リポジトリの Secret `GDRIVE_TOKEN` を設定する(未設定ならアップロードだけスキップ):

1. PC に [rclone](https://rclone.org/downloads/) を入れる
2. `rclone authorize "drive"` を実行 → ブラウザで Google にログインして許可
3. ターミナルに出る `{"access_token":...}` の1行JSONを丸ごとコピー
4. GitHub → Settings → Secrets and variables → Actions → New repository secret
   - Name: `GDRIVE_TOKEN` / Secret: コピーしたJSON

## ビルドが落ちたら

Actions のログのエラーを貼ってもらえれば直す。よくある原因:

- llama.cpp の API 変更 → `Yorozu/Core/LlamaEngine.swift` を修正
  (ビルドが通ったら `.github/workflows/build-ios.yml` の `LLAMA_TAG` を固定しておくと壊れにくい)
- xcframework の zip の名前/構造が違う → workflow の `Fetch llama.cpp xcframework` を修正

## 機能を足すとき

`Yorozu/Features/<名前>/` を作って、`Yorozu/App/MiniApps.swift` の `MiniApp.all` に1行足すとホームに並ぶ。
よく使うものは `Yorozu/App/YorozuApp.swift` の `TabView` にタブとしても足せる。

## 機能

- **ホーム**: よろず内のアプリ一覧、モデル/ダウンロード/メモリの状態、最近の会話
- **会話履歴**: 会話は自動保存。検索・名前変更・削除。チャット左上の時計アイコンかホームから開く
- **チャット**: ローカルLLM(llama.cpp / Metal)。iOS 26 ではリキッドグラスの見た目。返答はマークダウン表示(見出し・箇条書き・コードブロック・表・引用)
- **コピー/再生成**: 返答の下のボタン、または吹き出しの長押しでコピー・範囲を選んでコピー・再生成
- **メモリ節約**: モデルはチャットを開いた時だけ読み込み、裏に回すと解放(設定で変更可)。KVキャッシュは8bit圧縮、会話の続きはキャッシュを使い回して速く返答
- **ダイナミックアイランド常駐**: 設定でオン/オフ。モデル状態・返答・ダウンロード進捗を表示(iOSの仕様で8時間で消える。アプリを開くと再表示)
- **バックグラウンドダウンロード**: ホームに戻っても/ロックしても続く。上スワイプで強制終了した時だけ止まる。回線が切れたら続きから再開

## 注意

- 日本語 + 無検閲 + 軽量、を全部満たすモデルは少ない。まず標準版で動作確認 → abliterated 版、の順がおすすめ。
- 無検閲モデルの出力は自分の責任で。ローカル動作なので会話は外に出ない。
- バックグラウンドに回すとiOSがGPU処理を止めるので、生成中は画面を閉じない(裏に回ると自動で止まる)。
- `increased-memory-limit` の entitlement は Sideloadly の再署名で残らない可能性あり。
  メモリで落ちるなら設定でコンテキスト長を下げるか、より小さいモデルを使う。
