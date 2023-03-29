vim.cmd("packadd vim-jetpack")
require("jetpack.packer").add {
    {"tani/vim-jetpack", opt = 1},
    -- lsp
    {"neoclide/coc.nvim", branch = "release"},
    -- devicons
    "kyazdani42/nvim-web-devicons",
    -- indent
    "lukas-reineke/indent-blankline.nvim",
    -- finder
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope.nvim", tag = "0.1.1"
    },
    "fannheyward/telescope-coc.nvim",
    -- "junegunn/fzf.vim",
    -- {"junegunn/fzf", run = "call fzf#install()"},
    -- "ibhagwan/fzf-lua",
    -- treesitter
    {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"},
    -- appearance
    "joshdick/onedark.vim",
    "sainnhe/gruvbox-material",
    "sainnhe/sonokai",
    "jacoborus/tender.vim",
    -- status bar
    {
        "nvim-lualine/lualine.nvim",
    },
    -- tagbar
    "akinsho/bufferline.nvim",
    -- scroll bar
    {"petertriho/nvim-scrollbar",config = function()
      require("scrollbar").setup()
    end
    },
    {"lewis6991/gitsigns.nvim",config = function()
      require("gitsigns").setup()
      require("scrollbar.handlers.gitsigns").setup()
    end
    },
    {"kevinhwang91/nvim-hlslens",config = function()
      require("hlslens").setup({
        build_position_cb = function(plist, _, _, _)
          require("scrollbar.handlers.search").handler.show(plist.start_pos)
        end
      })
    end
    },
    -- filer
    {
        "kyazdani42/nvim-tree.lua",
        tag = "nightly" -- optional, updated every week. (see issue #1193)
    },
    -- utils
    "ap/vim-css-color",
    "machakann/vim-sandwich",
    "alvan/vim-closetag",
    -- comment
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },
    -- code formatter
    {"prettier/vim-prettier", run = {"yarn install --frozen-lockfile --production"}},
    -- jump
    {
        "phaazon/hop.nvim",
        branch = "v1", -- optional but strongly recommended
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require "hop".setup {keys = "asdfjkl;qweruiop"}
        end
    },
    -- Git
    "tpope/vim-fugitive",
  }
