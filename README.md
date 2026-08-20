# dotfiles

macOSとLinux向けの開発環境セットアップ用dotfilesリポジトリです。

## セットアップ

### 実行方法

```bash
# リポジトリをクローン
git clone https://github.com/username/dotfiles.git
cd dotfiles

# Bun導入 + 対話式インストーラー起動
./setup.sh
```

`setup.sh` は最初に Bun をインストール（未導入時のみ）し、その後 `bun run setup.ts` を実行します。
`setup.ts` は `citty` ベースの対話型 CLI で、各ツールを順番にインストールするか確認します。
すでに導入済みのツールはインストール済みバージョンと最新バージョンを表示し、最新なら自動スキップされます。

### オプション

```bash
# 既存設定のシンボリックリンク上書きを許可
./setup.sh --force

# 確認をスキップして進める
./setup.sh --yes

# 実際には変更せず、実行内容だけ確認
./setup.sh --dryRun   # --dry-run も同じ
```

## インストールされるツール

- **Bun**（`setup.sh` で最初に導入）
- **Neovim**（最新版、0.11+）
- **uv**（Python package and project manager）
- **Claude Code**（Anthropic CLI）
- **Codex CLI**
- **Gemini CLI**
- **opencode**
- **herdr**（AI コーディングエージェント向けターミナルマルチプレクサ）
- **eza**
- **zsh** + **Oh My Zsh**（`zsh-autosuggestions` / `zsh-syntax-highlighting` プラグイン込み）

## 配置される設定

すべてシンボリックリンクで配置します。`~/.claude` や `~/.codex` には
エージェントが生成する会話履歴やキャッシュが同居するため、
ディレクトリ全体ではなく管理対象のエントリだけを個別にリンクします。

| リンク元（リポジトリ） | リンク先 |
|------|------|
| `nvim/` | `~/.config/nvim` |
| `zsh/.zshrc` | `~/.zshrc` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/commands/*` | `~/.claude/commands/*` |

グローバル指示（`claude/CLAUDE.md`）と skills（`claude/skills/*`）は
Claude Code / Codex / opencode で同じ内容を使うため、実体を `claude/` に一本化し、
各ハーネスが読む名前・場所へリンクします。

| リンク元（リポジトリ） | リンク先 | ハーネス |
|------|------|------|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Claude Code |
| `claude/CLAUDE.md` | `~/.codex/AGENTS.md` | Codex |
| `claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` | opencode |
| `claude/skills/*` | `~/.claude/skills/*` | Claude Code |
| `claude/skills/*` | `~/.agents/skills/*` | Codex（USER スコープ） |
| `claude/skills/*` | `~/.config/opencode/skills/*` | opencode |

Codex のユーザースキルは `~/.agents/skills` に置きます。`~/.codex/skills` は
Codex 同梱のシステムスキル置き場なので触りません。

リンク先に実体がある場合は `.backup` を作成したうえで `--force` 指定時のみ置き換えます。

## Neovim設定

### プラグイン構成

- **rose-pine** - カラーテーマ
- **bufferline.nvim** - タブバー
- **lualine.nvim** - ステータスバー
- **indent-blankline.nvim** - インデント表示
- **hop.nvim** - 高速移動
- **nvim-treesitter** - シンタックスハイライト
- **telescope.nvim** - ファジーファインダー
- **nvim-tree.lua** - ファイルツリー
- **mason.nvim** - LSPサーバー管理
- **mason-lspconfig.nvim** - LSP設定

### キーマップ

#### NORMAL モード

| キー | 機能 |
|------|------|
| `;` | `:` |
| `<Leader>b` | 前のバッファ |
| `<Leader>n` | 次のバッファ |
| `<A-[>` | ハイライト無効化 |
| `<Leader>pref` | init.lua編集 |
| `<Leader>plug` | plugins.lua編集 |
| `<Leader>sjis` | Shift-JISエンコーディングで開く |

#### hop.nvim

| キー | 機能 |
|------|------|
| `<Leader>m` | キャメルケース移動 |

#### telescope.nvim

| キー | 機能 |
|------|------|
| `<Leader>ff` | ファイル検索 |
| `<Leader>fg` | Git管理ファイル検索 |
| `<Leader>fr` | 文字列検索 |
| `<Leader>fb` | バッファ検索 |
| `<Leader>fh` | ヘルプ検索 |
| `<Leader>e` | 診断情報 |
| `<Leader>o` | treesitter |

#### nvim-tree.lua

| キー | 機能 |
|------|------|
| `<Leader>t` | ファイルツリー表示切替 |

#### LSP

| キー | 機能 |
|------|------|
| `gh` | ホバー情報表示 |
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |

#### INSERT モード

| キー | 機能 |
|------|------|
| `<C-s>` | 保存してノーマルモードへ |
| `<A-[>` | ノーマルモードへ |
| `<A-x>` | 削除 |
| `<C-h>` | 左移動 |
| `<C-j>` | 下移動 |
| `<C-k>` | 上移動（LSP補完） |
| `<C-l>` | 右移動 |

#### TERMINAL モード

| キー | 機能 |
|------|------|
| `<ESC>` | ノーマルモードへ |

### LSP機能

- 自動補完（Neovim 0.11+組み込み機能使用）
- 保存時自動フォーマット
- mason.nvimによるLSPサーバー管理
- 日本語文字エンコーディング対応（UTF-8, UTF-16, EUC-JP, Shift-JIS）

## キーボード設定

- [Choco60 rev.2](https://keys.recompile.net/projects/choco60-rev2/)用キーマップ
- 手動設定が必要（自動セットアップ対象外）

## 対応OS

- macOS（Intel/Apple Silicon）
- Linux（Ubuntu/Debian系、CentOS/RHEL系）

## 注意事項

- 既存の設定ファイルは`.backup`として保存されます
- インターネット接続が必要です
- 実行前に重要なファイルのバックアップを推奨します
- Claude Codeの認証は初回利用時に手動で実施してください
