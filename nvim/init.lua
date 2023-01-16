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
opt.fileencodings = {"utf-8", "utf-16", "euc-jp", "sjis"}
opt.fileformats = {"unix", "dos", "mac"}
opt.ignorecase = true
opt.smartcase = true

vim.cmd("set signcolumn=yes")
vim.cmd("set mouse=")
-- color scheme
vim.cmd("colorscheme gruvbox-material")

-- lualine
require("lualine").setup {
    options = {
        theme = "gruvbox"
    }
}

-- key remap
if vim.fn.has("win32") == 1 then
    keymap.set("n", "<C-z>", "u", {remap = true})
end

vim.g.mapleader = " "
keymap.set("n", "<Leader>b", ":bprev<CR>")
keymap.set("n", "<Leader>n", ":bnext<CR>")
keymap.set("n", "<Leader>f", "<cmd>lua require('fzf-lua').files()<CR>")
keymap.set("n", "<Leader>gf", "<cmd>lua require('fzf-lua').git_files()<CR>")
keymap.set("n", "<Leader>grep", "<cmd>lua require('fzf-lua').live_grep()<CR>")
keymap.set("n", "<Leader>pref", ":e $MYVIMRC<CR>")
keymap.set("n", "<Leader>plug", ":e ~/.config/nvim/lua/plugins.lua<CR>")
keymap.set("n", "<Leader>coc", ":e ~/.config/nvim/lua/coc.lua<CR>")
keymap.set("n", "<Leader>sjis", ":e ++encoding=sjis<CR>:w")
keymap.set("t", "<Esc>", "<C-\\><C-n>")

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
vim.cmd [[highlight IndentBlanklineIndent1 guibg=#142728 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#402D09 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent3 guibg=#3d0a08 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent4 guibg=#2d2d07 gui=nocombine]]

require("indent_blankline").setup {
    char = "",
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4"
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4"
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



