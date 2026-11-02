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

## ビルドが落ちたら

Actions のログのエラーを貼ってもらえれば直す。よくある原因:

- llama.cpp の API 変更 → `Yorozu/Core/LlamaEngine.swift` を修正
  (ビルドが通ったら `.github/workflows/build-ios.yml` の `LLAMA_TAG` を固定しておくと壊れにくい)
- xcframework の zip の名前/構造が違う → workflow の `Fetch llama.cpp xcframework` を修正

## 機能を足すとき

`Yorozu/Features/<名前>/` を作って、`Yorozu/App/YorozuApp.swift` の `TabView` にタブを1つ足す。

## 注意

- 日本語 + 無検閲 + 軽量、を全部満たすモデルは少ない。まず標準版で動作確認 → abliterated 版、の順がおすすめ。
- 無検閲モデルの出力は自分の責任で。ローカル動作なので会話は外に出ない。
- バックグラウンドに回すとiOSがGPU処理を止めるので、生成中は画面を閉じない(裏に回ると自動で止まる)。
- `increased-memory-limit` の entitlement は Sideloadly の再署名で残らない可能性あり。
  メモリで落ちるなら設定でコンテキスト長を下げるか、より小さいモデルを使う。
