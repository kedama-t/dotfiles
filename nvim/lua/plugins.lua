vim.cmd("packadd vim-jetpack")
require("jetpack.packer").add {
    {"tani/vim-jetpack", opt = 1},
    -- outline
    {
        "stevearc/aerial.nvim",
        config = function()
            require("aerial").setup()
        end
    },
    -- devicons
    "kyazdani42/nvim-web-devicons",
    -- indent
    "lukas-reineke/indent-blankline.nvim",
    -- finder
    "junegunn/fzf.vim",
    {"junegunn/fzf", run = "call fzf#install()"},
    "ibhagwan/fzf-lua",
    -- lsp
    {"neoclide/coc.nvim", branch = "release"},
        -- treesitter
    {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"},
    -- appearance
    "sainnhe/gruvbox-material",
    -- status bar
    {
        "nvim-lualine/lualine.nvim",
    },
    -- tagbar
    {"akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons"},
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
    -- diagnostics
    {"folke/trouble.nvim",config=function() require("trouble").setup() end}

  }
