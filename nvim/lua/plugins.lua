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

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      local nvim_lsp = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')

      -- nvim-cmp settings
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
        }),
      })
      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' },
        }, {
          { name = 'buffer' },
        }),
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- mason settings
      mason_lspconfig.setup_handlers({ function(server_name)
        local opts = { capabilities }
        opts.on_attach = function(_, bufnr)
          local bufopts = { silent = true, buffer = bufnr }
          keymap.set('n', 'gi', lsp.buf.implementation, bufopts)
          keymap.set('n', 'gr', lsp.buf.references, bufopts)
          keymap.set('n', 'gT', lsp.buf.type_definition, bufopts)
          keymap.set('n', 'gD', lsp.buf.declaration, bufopts)
          keymap.set('n', 'gd', lsp.buf.definition, bufopts)
          keymap.set('n', 'ga', lsp.buf.code_action, bufopts)
          keymap.set('n', 'K', lsp.buf.hover, bufopts)
          keymap.set('n', '<C-k>', lsp.buf.signature_help, bufopts)
          keymap.set('n', 'gf', lsp.buf.format, bufopts)
          keymap.set('n', 'ge', vim.diagnostic.open_float, bufopts)
          keymap.set('n', 'g[', vim.diagnostic.goto_next, bufopts)
          keymap.set('n', 'g]', vim.diagnostic.goto_prev, bufopts)
        end

        -- Lua
        if server_name == 'sumneko_lua' then
          opts.settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
            },
          }
        end

        nvim_lsp[server_name].setup(opts)
      end })
    end,
  },

  -- none-ls
  {
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require('null-ls')

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            condition = function(utils)
              return utils.has_file { ".prettierrc", ".prettierrc.js" }
            end,
            prefer_local = "node_modules/.bin"
          })
        }
      })
    end,
  },
}
