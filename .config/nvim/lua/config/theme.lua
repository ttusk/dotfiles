local opt = vim.opt

opt.termguicolors = true
opt.background = "light"

require("solarized").setup({})
vim.cmd.colorscheme("solarized")
