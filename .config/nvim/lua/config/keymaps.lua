local telescope = require("telescope.builtin")

local function map(lhs, rhs, description)
    vim.keymap.set("n", lhs, rhs, {
        silent = true,
        desc = description,
    })
end
local function current_buffer_directory()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then
        return vim.fn.getcwd()
    end
    return vim.fn.fnamemodify(filename, ":p:h")
end

map("<leader>fc", function()
    telescope.find_files({ cwd = current_buffer_directory() })
end, "Find files in current directory")

map("<leader>e", "<cmd>NvimTreeFocus<cr>", "Focus file tree")
map("<leader>gg", "<cmd>LazyGit<cr>", "Open LazyGit")
map("<leader>ff", telescope.find_files, "Find files")
map("<leader>fg", telescope.live_grep, "Search text")
map("<leader>fb", telescope.buffers, "Find buffers")
map("<leader>bn", "<cmd>enew<cr>", "New buffer")
map("<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")
map("[b", "<cmd>bprevious<cr>", "Previous buffer")
map("]b", "<cmd>bnext<cr>", "Next buffer")
map("<leader>fh", telescope.help_tags, "Search help")
map("<leader>he", telescope.keymaps, "Show keymaps")
map("<leader>d", function()
    vim.diagnostic.open_float(0, { scope = "line" })
end, "Show line diagnostics")
map("<leader>dd", function()
    telescope.diagnostics({ bufnr = 0 })
end, "Show buffer diagnostics")
map("<leader>dw", telescope.diagnostics, "Show workspace diagnostics")
map("gd", vim.lsp.buf.definition, "Go to definition")
map("K", vim.lsp.buf.hover, "Show method signature and documentation")
map("<leader>pd", telescope.lsp_definitions, "Peek method definition")
map("gI", vim.lsp.buf.implementation, "Go to implementation")
map("gr", vim.lsp.buf.references, "Find references")
map("grn", vim.lsp.buf.rename, "Rename symbol across project")

map("<leader>fm", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format buffer")
map("<leader>lr", "<cmd>lsp restart<cr>", "Restart LSP")
map("<leader>rr", function()
    local config = vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua")
    vim.cmd("source " .. config)
end, "Reload Neovim config")

map("<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")
vim.keymap.set("n", "<A-j>", "<cmd>move .+1<cr>==", {
    silent = true,
    desc = "Move line down",
})
vim.keymap.set("n", "<A-k>", "<cmd>move .-2<cr>==", {
    silent = true,
    desc = "Move line up",
})
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv=gv", {
    silent = true,
    desc = "Move selection down",
})
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv=gv", {
    silent = true,
    desc = "Move selection up",
})

local function completion_navigation(forward)
    if vim.fn.pumvisible() == 1 then
        return forward and "<C-n>" or "<C-p>"
    end

    local direction = forward and 1 or -1
    if vim.snippet.active({ direction = direction }) then
        vim.snippet.jump(direction)
        return ""
    end

    return forward and "<Tab>" or "<S-Tab>"
end

vim.keymap.set({ "i", "s" }, "<Tab>", function()
    return completion_navigation(true)
end, { expr = true, replace_keycodes = true, silent = true, desc = "Next completion or snippet placeholder" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    return completion_navigation(false)
end, { expr = true, replace_keycodes = true, silent = true, desc = "Previous completion or snippet placeholder" })

local function accept_completion()
    local completion = vim.fn.complete_info({ "selected" })
    if vim.fn.pumvisible() == 1 and completion.selected >= 0 then
        return "<C-y>"
    end
    return "<CR>"
end

vim.keymap.set("i", "<CR>", accept_completion, {
    expr = true,
    replace_keycodes = true,
    silent = true,
    desc = "Accept completion",
})

vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, {
    silent = true,
    desc = "Trigger completion",
})
vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
    expr = true,
    replace_keycodes = false,
    silent = true,
    desc = "Accept Copilot suggestion",
})
map("<leader>ct", function()
    if vim.g.copilot_enabled == 0 then
        vim.cmd("Copilot enable")
    else
        vim.cmd("Copilot disable")
    end
end, "Toggle Copilot suggestions")
