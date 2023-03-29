require "plugins"
require "coc"
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
opt.winblend = 10
opt.fileencodings = {"utf-8", "utf-16", "euc-jp", "sjis"}
opt.fileformats = {"unix", "dos", "mac"}
opt.ignorecase = true
opt.smartcase = true

vim.cmd("set signcolumn=yes")
vim.cmd("set mouse=")
-- color scheme
-- vim.cmd("colorscheme gruvbox-material")
-- vim.cmd("colorscheme onedark")
<<<<<<< HEAD
vim.cmd("let g:sonokai_style = 'shusia'")
vim.cmd("let g:sonokai_better_performance = 1")
=======
>>>>>>> 254733ddc71f402703c7ed69ca610a353799a849
vim.cmd("colorscheme sonokai")

-- lualine
require("lualine").setup {
    options = {
        -- theme = "gruvbox"
        -- theme = "onedark"
        theme = "sonokai"
    }
}

-- key remap
if vim.fn.has("win32") == 1 then
    keymap.set("n", "<C-z>", "u", {remap = true})
end

vim.g.mapleader = " "
keymap.set("n", "<A-[>", ":nohl<CR>")
keymap.set("i", "<C-s>", "<ESC>:w<CR>")
keymap.set("i", "<A-[>", "<ESC>")
keymap.set("i", "<A-x>", "<del>")
keymap.set("i", "<C-h>", "<left>")
keymap.set("i", "<C-j>", "<down>")
keymap.set("i", "<C-k>", "<up>")
keymap.set("i", "<C-l>", "<right>")
keymap.set("n", "<Leader>b", ":bprev<CR>")
keymap.set("n", "<Leader>n", ":bnext<CR>")
keymap.set("n", "<Leader>pref", ":e $MYVIMRC<CR>")
keymap.set("n", "<Leader>plug", ":e ~/.config/nvim/lua/plugins.lua<CR>")
keymap.set("n", "<Leader>coc", ":e ~/.config/nvim/lua/coc.lua<CR>")
keymap.set("n", "<Leader>cocs", ":e ~/.config/nvim/coc-settings.json<CR>")
keymap.set("n", "<Leader>sjis", ":e ++encoding=sjis<CR>:w")
keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- finder
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require('telescope.actions').close
      }
    },
    prompt_prefix = "🔍 ",
  }
}

local builtin = require("telescope.builtin")
local opts = {silent = true, nowait = true}
keymap.set("n", "<Leader>f", builtin.find_files, opts)
keymap.set("n", "<Leader>g", builtin.git_files, opts)
keymap.set("n", "<Leader>fb", builtin.current_buffer_fuzzy_find, opts)
keymap.set("n", "<Leader>fc", builtin.commands, opts)
keymap.set("n", "<Leader>grep", builtin.live_grep, opts)
keymap.set("n", "<Leader>e", ":Telescope coc diagnostics<CR>", opts)
keymap.set("n", "<Leader>d", ":Telescope coc definitions<CR>", opts)
keymap.set("n", "<Leader>y", ":Telescope coc type_definitions<CR>", opts)
keymap.set("n", "<Leader>r", ":Telescope coc references<CR>", opts)

-- treesitter
require("nvim-treesitter.configs").setup {
    ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "dart"
    },
    highlight = {
        enable = true
    }
}

-- indent
<<<<<<< HEAD
vim.cmd [[highlight IndentBlanklineIndent1 guibg=#2d2a2e gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#453B44 gui=nocombine]]
=======
vim.cmd [[highlight IndentBlanklineIndent1 guibg=#2c2e34 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#4c4f5a gui=nocombine]]
>>>>>>> 254733ddc71f402703c7ed69ca610a353799a849

require("indent_blankline").setup {
    char = "",
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    show_trailing_blankline_indent = false
}

-- label jump
keymap.set("n", "<Leader>m", ":HopWord<CR>")
keymap.set("n", "<Leader>,", ":HopChar1<CR>")

-- tagbar
require("bufferline").setup {}

-- filer
require("nvim-tree").setup {
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
            list = {}
        }
    }
}
keymap.set("n", "<Leader>t", ":NvimTreeToggle<CR>")
api.nvim_tree_quit_on_open = 1
