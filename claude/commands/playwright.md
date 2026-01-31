Bash tool を使って Playwright CLI でブラウザの動作検証を行ってください。

## 主要コマンド

- テスト実行: `npx playwright test [options] [test-filter...]`
  - `--headed`: ブラウザを表示して実行
  - `--debug`: Playwright Inspector でデバッグ
  - `--ui`: インタラクティブ UI モードで起動
  - `-g <grep>`: 正規表現でテストをフィルタリング
  - `--project <name>`: 特定プロジェクトのみ実行
- コード生成: `npx playwright codegen [url]`
  - `-o <file>`: 出力ファイル指定
  - `-b <browser>`: ブラウザ選択
- トレース表示: `npx playwright show-trace [trace]`
- レポート表示: `npx playwright show-report`
- ブラウザインストール: `npx playwright install [browser...]`

## 使い方

ユーザーの指示に応じて適切な Playwright CLI コマンドを実行してください。URL が指定された場合は `npx playwright codegen <url>` でブラウザを開きます。テストファイルが指定された場合は `npx playwright test` で実行します。
