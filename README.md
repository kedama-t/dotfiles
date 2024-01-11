# dotfiles

## Neovim

### NORMAL

- `;` - `:`
- `<Leader>b` - `:bprev<CR>`(previous buffer)
- `<Leader>n` - `:bnext<CR>`(next buffer)
- `<A-[>` - `:nohl`(disable highlight)

#### hop.nvim
- `<Leader>m` - `:HopCamelCase<CR>`

#### telescope.nvim
- `<Leader>ff` - `builtin.find_files`
- `<Leader>fg` - `builtin.git_files`
- `<Leader>fr` - `builtin.live_grep`
- `<Leader>fb` - `builtin.buffers`
- `<Leader>fh` - `builtin.help_tags`
- `<Leader>e` - `builtin.diagnostics`

#### nvim-tree.lua

- `<Leader>t` - `:NvimTreeToggle<CR>`

#### LSP

- `gi` - `vim.lsp.buf.implementation`
- `gr` - `vim.lsp.buf.references`
- `gT` - `vim.lsp.buf.type_definition`
- `gD` - `vim.lsp.buf.declaration`
- `gd` - `vim.lsp.buf.definition`
- `ga` - `vim.lsp.buf.code_action`
- `K` - `vim.lsp.buf.hover`
- `<C-k>` - `vim.lsp.buf.signature_help`
- `gf` - `vim.lsp.buf.format`
- `ge` - `vim.diagnostic.open_float`
- `g[` - `vim.diagnostic.goto_next`
- `g]` - `vim.diagnostic.goto_prev`

#### Prettier

- `<C-p>` - code format with Prettier

### INSERT

#### nvim-cmp
- `<C-b>` - `cmp.mapping.scroll_docs(-4)`
- `<C-f>` - `cmp.mapping.scroll_docs(4)`
- `<C-Space>` - `cmp.mapping.complete()`
- `<C-e>` - `cmp.mapping.abort()`
- `<CR>` - `cmp.mapping.confirm({ select = false })`
- `<Tab>` - `cmp.mapping.confirm({ select = true })`

### TERMINAL
- `<ESC>` - `<C-\><C-n>`

## Keyboard
- Keymap for [Choco60 rev.2](https://keys.recompile.net/projects/choco60-rev2/)