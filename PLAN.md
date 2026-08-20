# Environment Setup Script Plan

## 概要

Mac および Linux で共通して使える環境構築スクリプトの仕様書。
エントリポイントは `setup.sh`（Bun のブートストラップのみ）、本体は `setup.ts`。

## 目的

- dotfiles リポジトリの設定を自動でシステムに適用
- Mac（Homebrew）と Linux（apt/dnf/yum）両方に対応
- 冪等性を保証（何度実行しても安全）

## 対象 OS

- macOS（Intel/Apple Silicon）
- Linux（Ubuntu/Debian 系、CentOS/RHEL 系）

## セットアップ内容

### 1. ツールのインストール

`setup.ts` は各ツールについて「インストール済みバージョン」と「最新バージョン」を取得し、
最新でなければインストール／更新するかを対話で確認する。

| ツール | 用途 | バージョン取得元 | インストール方法 |
|------|------|------|------|
| Bun | JS/TS ランタイム・パッケージマネージャ | - | `setup.sh` が `curl -fsSL https://bun.sh/install \| bash` で先に導入 |
| Neovim（0.11+） | エディタ | GitHub releases | brew / apt（neovim-ppa）/ dnf / yum |
| uv | Python パッケージ・プロジェクト管理 | GitHub releases | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Claude Code | Anthropic CLI | npm registry | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Codex CLI | OpenAI CLI | npm registry | `bun add -g @openai/codex` |
| Gemini CLI | Google CLI | npm registry | `bun add -g @google/gemini-cli` |
| herdr | AI コーディングエージェント向けターミナルマルチプレクサ | GitHub releases | macOS は `brew install herdr`、他は `curl -fsSL https://herdr.dev/install.sh \| sh` |
| eza | `ls` の代替（`.zshrc` でエイリアス） | GitHub releases | brew / apt / dnf / yum |

### 2. Zsh 環境のセットアップ

`.zshrc` が Oh My Zsh とプラグインの存在を前提にしているため、
シンボリックリンクを張る前に以下を用意する。

- zsh 本体（未導入ならパッケージマネージャで導入）
- Oh My Zsh（`--unattended --keep-zshrc` で導入。dotfiles の `.zshrc` を保護する）
- `zsh-autosuggestions` / `zsh-syntax-highlighting`（`$ZSH/custom/plugins/` へ `git clone`）

### 3. 設定ファイルの配置

すべてシンボリックリンクで配置する。

```
~/.config/nvim            -> nvim/
~/.zshrc                  -> zsh/.zshrc
~/.claude/CLAUDE.md       -> claude/CLAUDE.md
~/.claude/settings.json   -> claude/settings.json
~/.claude/references      -> claude/references/
~/.claude/commands/*      -> claude/commands/*
~/.claude/skills/*        -> claude/skills/*
~/.codex/skills/*         -> codex/skills/*
```

`~/.claude` と `~/.codex` にはエージェントが生成する会話履歴・セッション・キャッシュが
同居するため、ディレクトリ単位ではなく **エントリ単位** でリンクする。
ディレクトリごとコピー／置換すると、これらのデータを巻き込んで消してしまう。

リンク先に実体がある場合は `.backup` を作成したうえで、`--force` 指定時のみ置き換える。
指定がなければ警告してスキップする。

配置後、`nvim` があれば `nvim --headless '+Lazy! sync' +qa` でプラグインを同期する
（lazy.nvim 自体は `nvim/init.lua` が起動時に自動ブートストラップする）。

### 4. 実装仕様

#### 冪等性の保証

- インストール前に既存バージョンを確認し、最新なら対話をスキップ
- シンボリックリンクが既に正しい向きなら何もしない
- 置き換え時は `.backup` を作成（既に存在する場合は上書きしない）

#### エラーハンドリング

- 各ツールのインストール結果を `installed` / `skipped` / `failed` で集計し、最後にサマリを表示
- 1 つでも `failed` があれば終了コード 1

#### オプション

| オプション | 内容 |
|------|------|
| `--dryRun`（`--dry-run`） | 実行内容の表示のみ。ファイルは一切変更しない |
| `--force` | シンボリックリンク先に実体がある場合も置き換える |
| `--yes` | 対話確認をスキップしてすべて実行する |
| `--help` | ヘルプ表示（`setup.sh` が処理） |

### 5. 使用方法

```bash
./setup.sh              # 基本実行
./setup.sh --dry-run    # ドライラン
./setup.sh --force      # 既存設定の置き換えを許可
./setup.sh --yes        # 確認をスキップ
```

### 6. 注意事項

- パッケージインストールで sudo を求められる場合がある
- 置き換えられた設定ファイルは `.backup` として保存される
- インターネット接続が必要
- Claude Code / Codex / Gemini の認証は初回利用時にユーザーが実施する

### 7. 未実装 / 今後の拡張予定

- 汎用ツール（git、curl、fzf、gh）のインストール
- `--minimal`（最小限のツールのみインストール）
- デフォルトシェルの zsh への変更（`chsh` が対話的なため手動）
- 失敗時のロールバック
- Git 設定の自動適用
- 他のエディタ（VSCode 等）の設定対応
- ターミナルエミュレータ・フォント設定

### 8. 対象外項目

- キーボード設定（Choco60 等）: 手動設定が必要なため除外
