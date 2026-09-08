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

local external_file_group = vim.api.nvim_create_augroup("external-file-sync", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
    group = external_file_group,
    command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShell", {
    group = external_file_group,
    callback = function(args)
        local bufnr = args.buf
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == "" then
            return
        end

        if vim.fn.filereadable(path) == 0 then
            vim.api.nvim_set_vvar("fcs_choice", "")
            if vim.b[bufnr].external_file_deleted then
                return
            end

            vim.b[bufnr].external_file_deleted = true
            vim.bo[bufnr].modified = true
            vim.notify(
                string.format("File deleted externally; buffer kept: %s", vim.fn.fnamemodify(path, ":~")),
                vim.log.levels.WARN
            )
            return
        end

        if vim.v.fcs_reason == "conflict" then
            vim.api.nvim_set_vvar("fcs_choice", "ask")
            vim.notify(
                string.format("External change conflicts with local edits: %s", vim.fn.fnamemodify(path, ":~")),
                vim.log.levels.WARN
            )
        else
            vim.api.nvim_set_vvar("fcs_choice", "edit")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = external_file_group,
    callback = function(args)
        vim.b[args.buf].external_file_deleted = nil
    end,
})

opt.laststatus = 2
opt.showmode = false
opt.showcmd = false
