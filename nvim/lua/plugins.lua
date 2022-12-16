vim.cmd [[packadd packer.nvim]]

return require('packer').startup(
  function()
    -- plugin manager
    use 'wbthomason/packer.nvim'

    -- LSP Support
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    -- Autocompletion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'saadparwaiz1/cmp_luasnip'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'

    -- Snippets
    use 'L3MON4D3/LuaSnip'
    use 'rafamadriz/friendly-snippets'

    use 'nvim-lua/lsp-status.nvim'

    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end
    }

    -- outline
    use {
      'stevearc/aerial.nvim',
      config = function() require('aerial').setup() end
    }
    -- indent
          use "lukas-reineke/indent-blankline.nvim"

    -- fuzzy finder
    use { 'junegunn/fzf', run = './install --bin', }
    use { 'ibhagwan/fzf-lua',
      -- optional for icon support
      requires = { 'kyazdani42/nvim-web-devicons' }
    }

    -- treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- appearance
    use 'sainnhe/gruvbox-material'
    use { 'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- tagbar
    use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' }

    -- filer
    use {
      'kyazdani42/nvim-tree.lua',
      requires = {
        'kyazdani42/nvim-web-devicons', -- optional, for file icon
      },
      tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    -- utils
    use 'ap/vim-css-color'
    use 'machakann/vim-sandwich'
    use 'alvan/vim-closetag'

    -- comment
    use {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end
    }

    -- code formatter
    use { 'prettier/vim-prettier', run = { "yarn install --frozen-lockfile --production" } }

    -- jump
    use {
      'phaazon/hop.nvim',
      branch = 'v1', -- optional but strongly recommended
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require 'hop'.setup { keys = 'asdfjkl;qweruiop' }
      end
    }

    -- Git
    use 'tpope/vim-fugitive'

    -- Flutter
    use 'dart-lang/dart-vim-plugin'
    use 'thosakwe/vim-flutter'
  end)
