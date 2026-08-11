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
map("<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")
