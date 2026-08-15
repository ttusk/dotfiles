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
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- Keep floating windows and completion menus in the same ASCII visual style
-- as the editor separators above.
local ascii_border = "+,-,+,|,+,-,+,|"
opt.winborder = ascii_border
opt.pumborder = ascii_border
opt.timeoutlen = 300

opt.autoread = true

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    command = "checktime",
})

local function autosave_buffer(args)
    local bufnr = args.buf
    local buffer = vim.bo[bufnr]
    if buffer.buftype ~= "" or buffer.readonly or not buffer.modifiable or not buffer.modified then
        return
    end
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        return
    end

    vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent update")
    end)
end

vim.api.nvim_create_autocmd({
    "BufLeave",
    "FocusLost",
    "InsertLeave",
    "TextChanged",
    "TextChangedI",
}, {
    callback = autosave_buffer,
    group = vim.api.nvim_create_augroup("auto-save", { clear = true }),
})

if vim.g.auto_checktime_timer then
    vim.fn.timer_stop(vim.g.auto_checktime_timer)
end

vim.g.auto_checktime_timer = vim.fn.timer_start(500, function()
    vim.cmd("checktime")
end, { ["repeat"] = -1 })
