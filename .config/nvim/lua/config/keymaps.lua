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
map("<leader>ff", telescope.find_files, "Find files")
map("<leader>fg", telescope.live_grep, "Search text")
map("<leader>fb", telescope.buffers, "Find buffers")
map("<leader>fh", telescope.help_tags, "Search help")
map("<leader>ml", "<cmd>MarkdownLint<cr>", "Lint Markdown buffer")
-- map("<leader>?", function()
--     require("which-key").show({ global = false })
-- end, "Show keymaps")
map("<leader>d", function()
    vim.diagnostic.open_float(0, { scope = "line" })
end, "Show diagnostic details")
map("gd", vim.lsp.buf.definition, "Go to definition")
map("gI", vim.lsp.buf.implementation, "Go to implementation")
map("gr", vim.lsp.buf.references, "Find references")

map("<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

local function completion_navigation(forward)
    if vim.fn.pumvisible() == 1 then
        return forward and "<C-n>" or "<C-p>"
    end
    return forward and "<Tab>" or "<S-Tab>"
end

local function accept_completion()
    local completion = vim.fn.complete_info({ "selected" })
    if vim.fn.pumvisible() == 1 and completion.selected >= 0 then
        return "<C-y>"
    end
    return "<CR>"
end

vim.keymap.set("i", "<Tab>", function()
    return completion_navigation(true)
end, { expr = true, replace_keycodes = true, silent = true, desc = "Next completion" })

vim.keymap.set("i", "<S-Tab>", function()
    return completion_navigation(false)
end, { expr = true, replace_keycodes = true, silent = true, desc = "Previous completion" })

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
