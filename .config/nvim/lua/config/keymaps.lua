local telescope = require("telescope.builtin")

local function map(lhs, rhs, description)
    vim.keymap.set("n", lhs, rhs, {
        silent = true,
        desc = description,
    })
end

map("<leader>e", "<cmd>NvimTreeFocus<cr>", "Focus file tree")
map("<leader>ff", telescope.find_files, "Find files")
map("<leader>fg", telescope.live_grep, "Search text")
map("<leader>fb", telescope.buffers, "Find buffers")
map("<leader>fh", telescope.help_tags, "Search help")
