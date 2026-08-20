# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository. Contains the Neovim configuration, zsh configuration,
shared configuration for AI coding agents (Claude Code / Codex), and a cross-platform
setup script that links them into the home directory.

```
setup.sh              # Bootstraps Bun, then runs setup.ts
setup.ts              # Interactive installer (citty-based CLI)
nvim/                 # Neovim config -> ~/.config/nvim
  init.lua            # Entry point (options, keymaps, LSP)
  lua/plugins.lua     # Plugin definitions
  lazy-lock.json      # Plugin version lockfile (managed by lazy.nvim)
zsh/.zshrc            # -> ~/.zshrc (assumes Oh My Zsh + plugins)
claude/               # -> linked entry by entry into ~/.claude
  CLAUDE.md           # Global user instructions
  settings.json       # Permissions and Claude Code settings
  references/         # Detailed guidance referenced from CLAUDE.md
  skills/             # Agent skills
codex/skills/         # -> linked entry by entry into ~/.codex/skills
keyboard/             # Choco60 rev.2 layout (manual setup, not automated)
```

## Setup Script

- `setup.sh` only bootstraps Bun and delegates to `setup.ts`; all real logic lives in `setup.ts`.
- Adding a tool means appending a `Tool` entry in `createTools()` with installed-version
  detection, latest-version lookup, and an install command.
- Config placement is **symlink only**. `~/.claude` and `~/.codex` hold agent-generated
  conversation history and caches, so they are linked entry by entry — never as a whole
  directory, which would delete that data.
- Verify changes with `bun run setup.ts --dryRun --yes`; it performs no writes.
- See `PLAN.md` for the full specification, including what is intentionally unimplemented.

## Neovim Configuration

### Key Architecture Decisions

1. **Plugin Manager**: lazy.nvim, bootstrapped automatically from `init.lua`
2. **Configuration Style**: modern Lua-based configuration (no legacy vimscript)
3. **LSP Setup**: mason.nvim + mason-lspconfig.nvim for LSP server management
4. **Completion**: built-in `vim.lsp.completion` (Neovim 0.11+) instead of an external plugin

### Core Plugin Categories

- **UI/Visual**: rose-pine colorscheme, lualine status bar, bufferline tabs, indent-blankline
- **Navigation**: telescope.nvim for fuzzy finding, nvim-tree for file explorer, hop.nvim for motion
- **LSP/Development**: mason.nvim ecosystem for language server management
- **Syntax**: nvim-treesitter for syntax highlighting and parsing

### Common Tasks

- Add new plugins to `nvim/lua/plugins.lua`; lazy.nvim installs them and updates `lazy-lock.json`.
- LSP servers are managed through mason.nvim; auto-formatting runs on save for LSP-capable buffers.
- Leader key is space. Global keymaps live in `nvim/init.lua`, plugin-specific ones in
  `nvim/lua/plugins.lua`. See README.md for the complete keymap reference.
- Encoding support is tuned for Japanese development (UTF-8, UTF-16, EUC-JP, Shift-JIS);
  `<Leader>sjis` reopens the current file as Shift-JIS.
