require 'plugins'
local opt = vim.opt
local keymap = vim.keymap
local api = vim.api

-- option
opt.termguicolors = true
opt.number = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.pumblend = 10
opt.fileencodings = { 'utf-8', 'utf-16', 'euc-jp', 'sjis' }
opt.fileformats = { 'unix', 'dos', 'mac' }
opt.ignorecase = true
opt.smartcase = true

vim.cmd('set signcolumn=yes')
vim.cmd('set mouse=')
-- color scheme
vim.cmd('colorscheme gruvbox-material')

-- lualine
require('lualine').setup {
  options = {
    theme = 'gruvbox',
  },
}

-- key remap
if vim.fn.has('win32') == 1 then
  keymap.set('n', '<C-z>', 'u', { remap = true })
end

vim.g.mapleader = ' '
keymap.set('n', '<Leader>b', ':bprev<CR>')
keymap.set('n', '<Leader>n', ':bnext<CR>')
keymap.set('n', '<Leader>f', "<cmd>lua require('fzf-lua').files()<CR>")
keymap.set('n', '<Leader>gf', "<cmd>lua require('fzf-lua').git_files()<CR>")
keymap.set('n', '<Leader>grep', "<cmd>lua require('fzf-lua').live_grep()<CR>")
keymap.set('n', '<Leader>pref', ':e $MYVIMRC<CR>')
keymap.set('n', '<Leader>plug', ':e ~/.config/nvim/lua/plugins.lua<CR>')
keymap.set('n', '<Leader>sjis', ':e ++encoding=sjis<CR>:w')
keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "lua",
    "javascript",
    "typescript",
    "tsx",
    "dart",
  },
  highlight = {
    enable = true,
  },
}

-- outline
keymap.set('n', '<Leader>o', ':AerialToggle right<CR>')
keymap.set('n', '<C-m>', ':AerialNext<CR>')
keymap.set('n', '<C-n>', ':AerialPrev<CR>')

-- indent
vim.cmd [[highlight IndentBlanklineIndent3 guibg=#3d0a08 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent4 guibg=#2d2d07 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#402D09 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent1 guibg=#142728 gui=nocombine]]

require("indent_blankline").setup {
  char = "",
  char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
  },
  space_char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
  },
  show_trailing_blankline_indent = false,
}

-- label jump
keymap.set('n', '<Leader>m', ':HopWord<CR>')
keymap.set('n', '<Leader>,', ':HopChar1<CR>')

--tagbar
require('bufferline').setup {}

-- filer
require('nvim-tree').setup {
  open_on_tab = false,
  view = {
    width = 50,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {
      },
    },
  }
}
keymap.set('n', '<Leader>t', ':NvimTreeToggle<CR>')
api.nvim_tree_quit_on_open = 1

--nvim-cmp
local cmp = require 'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

--lsp settings
require("nvim-lsp-installer").setup {}

local signs = { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' }

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  virtual_text = false,
})

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
api.nvim_set_keymap('n', '<Leader>db', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
api.nvim_set_keymap('n', '<Leader>dn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
api.nvim_set_keymap('n', '<Leader>de', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
api.nvim_set_keymap('n', '<Leader>e', ':TroubleToggle<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  -- code format
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>pp', '<cmd> lua vim.lsp.buf.format { async = true }<CR>', opts)
  api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>p', ':PrettierAsync<CR>', opts)
end

local lspConfig = require('lspconfig')
local servers = { 'volar', 'tsserver', 'eslint', 'dartls', 'golangci_lint_ls', 'gopls' }
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in pairs(servers) do
  lspConfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

-- lua lsp
lspConfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'use' },
      }
    }
  }
}
