local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Use ASCII characters for editor separators and empty lines.
opt.fillchars = {
    eob = " ",
    fold = "-",
    foldopen = "-",
    foldclose = "+",
    foldsep = "|",
    horiz = "-",
    horizup = "+",
    horizdown = "+",
    vert = "|",
    vertleft = "+",
    vertright = "+",
    verthoriz = "+",
}

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 300
