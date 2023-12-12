local opt = vim.opt
local keymap = vim.keymap
vim.g.mapleader = ' '

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
opt.rtp:prepend(lazypath)

local plugins = require('plugins')

require('lazy').setup(plugins)
--

-- option
if not vim.g.vscode then
  opt.termguicolors = true
  opt.number = true
  opt.expandtab = true
  opt.tabstop = 2
  opt.shiftwidth = 2
  opt.pumblend = 10
  opt.winblend = 10
  opt.fileencodings = { 'utf-8', 'utf-16', 'euc-jp', 'sjis' }
  opt.fileformats = { 'unix', 'dos', 'mac' }
  opt.ignorecase = true
  opt.smartcase = true

  vim.cmd('set signcolumn=yes')
  vim.cmd('set mouse=')
end

-- key remap
if vim.fn.has('win32') == 1 then
  keymap.set('n', '<C-z>', 'u', { remap = true })
end

-- for english keybard
keymap.set('n', ';', ':')

keymap.set('n', '<A-[>', ':nohl<CR>')
keymap.set('i', '<C-s>', '<ESC>:w<CR>')
keymap.set('i', '<A-[>', '<ESC>')
keymap.set('i', '<A-x>', '<del>')
keymap.set('i', '<C-h>', '<left>')
keymap.set('i', '<C-j>', '<down>')
keymap.set('i', '<C-k>', '<up>')
keymap.set('i', '<C-l>', '<right>')
keymap.set('n', '<Leader>b', ':bprev<CR>')
keymap.set('n', '<Leader>n', ':bnext<CR>')
keymap.set('n', '<Leader>pref', ':e $MYVIMRC<CR>')
keymap.set('n', '<Leader>plug', ':e ~/.config/nvim/lua/plugins.lua<CR>')
keymap.set('n', '<Leader>sjis', ':e ++encoding=sjis<CR>:w')
keymap.set('t', '<Esc>', '<C-\\><C-n>')
