local cmd = vim.cmd
local keymap = vim.keymap
local lsp = vim.lsp
local api = vim.api

return {
  -- color scheme
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup({ variant = "moon" })
      cmd([[colorscheme rose-pine]])
    end,
  },

  -- tab bar
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {}
    end,
  },

  -- status bar
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup({
        options = {
          section_separators = '',
          component_separators = '',
        },
      })
    end,
  },

  -- indent
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      local highlight = {
        "CursorColumn",
        "Whitespace",
      }
      require("ibl").setup {
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      }
    end
  },

  -- motion
  {
    'smoka7/hop.nvim',
    version = '*',
    opts = {},
    config = function()
      require('hop').setup()
      keymap.set('n', '<Leader>m', ':HopCamelCase<CR>')
    end,
  },

  -- tree sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({ highlight = { enable = true } })
    end
  },

  -- finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      keymap.set('n', '<Leader>ff', builtin.find_files, {})
      keymap.set('n', '<Leader>fg', builtin.git_files, {})
      keymap.set('n', '<Leader>fr', builtin.live_grep, {})
      keymap.set('n', '<Leader>fb', builtin.buffers, {})
      keymap.set('n', '<Leader>fh', builtin.help_tags, {})
      keymap.set('n', '<Leader>e', builtin.diagnostics, {})
      keymap.set('n', '<Leader>o', builtin.treesitter, {})
    end,
  },

  -- file tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-tree').setup()
      keymap.set('n', '<Leader>t', ':NvimTreeToggle<CR>')
    end,
  },

  -- Code Assistant
  {
    "github/copilot.vim",
  },
  -- LSP
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonUpdate", "MasonLog", "MasonInstall", "MasonUninstall", "MasonUninstallAll" },
    config = true,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim" },
      { "neovim/nvim-lspconfig" },
    },
    event = { "BufReadPre", "BufNewFile" },
    config = true,
    keys = {
      { "<C-k>", "<cmd>lua vim.lsp.completion.get()  <CR>",     mode = "i" },
      { "gh",    "<cmd>lua vim.lsp.buf.hover()       <CR>" },
      { "gd",    "<cmd>lua vim.lsp.buf.definition()  <CR>" },
      { "gD",    "<cmd>lua vim.lsp.buf.declaration() <CR>" },
      { "gf",    "<cmd>lua vim.lsp.buf.format()  <CR>" },
      { "gr",    "<cmd>lua vim.lsp.buf.references()  <CR>" },
      { "gi",    "<cmd>lua vim.lsp.buf.implementation()  <CR>" },
      { "gt",    "<cmd>lua vim.lsp.buf.type_definition()  <CR>" },
      { "gn",    "<cmd>lua vim.lsp.buf.rename()  <CR>" },
      { "ga",    "<cmd>lua vim.lsp.buf.code_action()  <CR>" },
      { "ge",    "<cmd>lua vim.diagnostic.open_float()  <CR>" },
      { "g]",    "<cmd>lua vim.diagnostic.goto_next()  <CR>" },
      { "g[",    "<cmd>lua vim.diagnostic.goto_prev()  <CR>" },
    },
  },
}
