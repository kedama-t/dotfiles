# Environment Setup Script Plan (setup.sh)

## 概要

Mac および Linux で共通して使える環境構築スクリプト`setup.sh`の仕様書

## 目的

- dotfiles リポジトリの設定を自動でシステムに適用
- Mac（homebrew）と Linux（apt/yum）両方に対応
- 冪等性を保証（何度実行しても安全）

## 対象 OS

- macOS（Intel/Apple Silicon）
- Linux（Ubuntu/Debian 系、CentOS/RHEL 系）

## セットアップ内容

### 1. 必須ツールのインストール

#### 共通ツール

- git
- curl
- fzf
- gh

#### 開発ツール

- Neovim（最新版、0.11+）
- Node.js 環境
  - fnm（Fast Node Manager）
- Python 環境
  - uv（Python package and project manager）
- Go（最新版）
- Claude Code（Anthropic CLI）

#### シェル環境

- zsh
- Oh My Zsh
- 推奨プラグイン（zsh-autosuggestions、zsh-syntax-highlighting）

#### その他のツール

- eza
  - `ls`を`eza -l --no-user`のエイリアスとして使います。

### 2. 設定ファイルの配置

#### Neovim 設定

- シンボリックリンクの作成

```
~/.config/nvim/init.lua -> dotfiles/nvim/init.lua
~/.config/nvim/lua/ -> dotfiles/nvim/lua/
```

- lazy.nvim の自動インストール
- 初回起動時のプラグイン同期

#### Zsh 設定

- シンボリックリンクの作成

```
~/.zshrc -> dotfiles/zsh/.zshrc
```

- Oh My Zsh の自動インストール
- デフォルトシェルを zsh に変更
- 推奨プラグインのインストール
  - zsh-autosuggestions
  - zsh-syntax-highlighting

#### Node.js 環境設定

- fnm（Fast Node Manager）のインストール
- Node.js LTS 版のインストールと設定
- npm グローバルパッケージの基本設定

#### Python 環境設定

- uv のインストール

#### Claude Code 設定

- Claude Code CLI のインストール
- 基本的な設定ファイルの配置
- 認証はユーザーが初回利用時に実施するので対応不要。

### 3. OS ごとの具体的なインストール方法

#### macOS

- Homebrew の自動インストール
- `brew install` コマンドでパッケージインストール
- fnm（Fast Node Manager）のインストール(`curl -fsSL https://fnm.vercel.app/install | bash`)
- uv のインストール（`curl -LsSf https://astral.sh/uv/install.sh | sh`）
- Claude Code のインストール（`npm install -g @anthropic-ai/claude-code`）
- macOS 特有の設定適用

#### Linux（Ubuntu/Debian）

- `apt update && apt install` でパッケージインストール
- AppImage や snap パッケージの利用（Neovim 等）
- fnm のインストール(`curl -fsSL https://fnm.vercel.app/install | bash`)
- uv のインストール（`curl -LsSf https://astral.sh/uv/install.sh | sh`）
- Claude Code のインストール（`npm install -g @anthropic-ai/claude-code`）

#### Linux（CentOS/RHEL）

- `yum install` または `dnf install` でパッケージインストール
- EPEL リポジトリの有効化
- fnm のインストール(`curl -fsSL https://fnm.vercel.app/install | bash`)
- uv のインストール（`curl -LsSf https://astral.sh/uv/install.sh | sh`）
- Claude Code のインストール（`npm install -g @anthropic-ai/claude-code`）

### 4. 実装仕様

#### スクリプト構造

```bash
#!/bin/bash

# OS検出
detect_os()

# パッケージマネージャー検出
detect_package_manager()

# 必須ツールインストール
install_essential_tools()

# 開発ツールインストール
install_dev_tools()

# Zsh + Oh My Zsh セットアップ
setup_zsh()

# Node.js環境セットアップ
setup_nodejs()

# Python環境セットアップ
setup_python()

# Claude Code セットアップ
setup_claude_code()

# Neovim設定配置
setup_neovim()

# シンボリックリンク作成
create_symlinks()

# 権限設定
set_permissions()

# インストール確認
verify_installation()
```

#### 冪等性の保証

- 既存インストールの確認
- バックアップファイルの作成
- 重複インストールの回避

#### エラーハンドリング

- 各ステップでの実行結果確認
- 失敗時のロールバック機能
- 詳細なログ出力

#### オプション機能

- `--dry-run`: 実行内容の確認のみ
- `--force`: 既存設定の強制上書き
- `--minimal`: 最小限のツールのみインストール

### 5. 使用方法

```bash
# 基本実行
./setup.sh

# ドライラン
./setup.sh --dry-run

# 強制実行
./setup.sh --force

# 最小インストール
./setup.sh --minimal
```

### 6. 注意事項

- 管理者権限が必要な場合は sudo を使用
- 既存の設定ファイルは`.backup`として保存
- インターネット接続が必要
- 実行前に重要なファイルのバックアップを推奨

### 7. 今後の拡張予定

- Git 設定の自動適用
- 他のエディタ（VSCode 等）の設定対応
- ターミナルエミュレータの設定
- フォント設定の自動化

### 8. 対象外項目

- キーボード設定（Choco60 等）: 手動設定が必要なため除外
