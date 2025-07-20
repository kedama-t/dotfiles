# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository focused on Neovim configuration. The repository contains:

- Neovim configuration using modern Lua-based setup with lazy.nvim plugin manager
- Keyboard layout configuration for Choco60 rev.2 keyboard

## Architecture and Structure

### Neovim Configuration Structure

```
nvim/
├── init.lua           # Main configuration entry point
├── lua/
│   └── plugins.lua    # Plugin definitions and configurations
└── lazy-lock.json     # Plugin version lockfile (managed by lazy.nvim)
```

### Key Architecture Decisions

1. **Plugin Manager**: Uses lazy.nvim for plugin management with lazy loading capabilities
2. **Configuration Style**: Modern Lua-based configuration (no legacy vimscript)
3. **LSP Setup**: Uses mason.nvim + mason-lspconfig.nvim for LSP server management
4. **Completion**: Uses built-in vim.lsp.completion (Neovim 0.11+) instead of external completion plugins

### Core Plugin Categories

- **UI/Visual**: rose-pine colorscheme, lualine status bar, bufferline tabs, indent-blankline
- **Navigation**: telescope.nvim for fuzzy finding, nvim-tree for file explorer, hop.nvim for motion
- **LSP/Development**: mason.nvim ecosystem for language server management
- **Syntax**: nvim-treesitter for syntax highlighting and parsing

## Common Development Tasks

### Plugin Management

- Add new plugins to `nvim/lua/plugins.lua`
- Plugin installations are automatically handled by lazy.nvim
- Lock file (`lazy-lock.json`) tracks exact plugin versions

### LSP Configuration

- LSP servers are managed through mason.nvim
- Auto-formatting is enabled for LSP-capable buffers on save
- Completion is triggered automatically while typing

### Key Configuration

- Leader key is set to space (`<Leader>` = ` `)
- Custom keymaps are defined in `nvim/init.lua` (global) and `nvim/lua/plugins.lua` (plugin-specific)
- See README.md for complete keymap reference

### File Encoding Support

- Configured for Japanese development with support for UTF-8, UTF-16, EUC-JP, and Shift-JIS encodings
- Special command `<Leader>sjis` for opening files with Shift-JIS encoding