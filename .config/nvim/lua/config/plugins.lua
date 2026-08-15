vim.pack.add({
    {
        src = "https://github.com/maxmx03/solarized.nvim",
        name = "solarized",
    },
    {
        src = "https://github.com/ellisonleao/gruvbox.nvim",
        name = "gruvbox",
    },
    {
        src = "https://github.com/nvim-tree/nvim-tree.lua",
        name = "nvim-tree",
    },
    {
        src = "https://github.com/nvim-lua/plenary.nvim",
        name = "plenary",
    },
    {
        src = "https://github.com/nvim-telescope/telescope.nvim",
        name = "telescope",
    },
    {
        src = "https://github.com/mfussenegger/nvim-lint",
        name = "nvim-lint",
    },
    {
        src = "https://github.com/lewis6991/gitsigns.nvim",
        name = "gitsigns",
    },
    {
        src = "https://github.com/kylechui/nvim-surround",
        name = "nvim-surround",
    },
    {
        src = "https://github.com/echasnovski/mini.nvim",
        name = "mini",
    },
    -- {
    --     src = "https://github.com/folke/which-key.nvim",
    --     name = "which-key",
    -- },
})

require("nvim-tree").setup({
    view = {
        width = 30,
    },
    renderer = {
        icons = {
            show = {
                file = false,
                folder = true,
                git = true,
                diagnostics = false,
                modified = false,
                bookmarks = false,
            },
            glyphs = {
                folder = {
                    arrow_closed = ">",
                    arrow_open = "v",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "@",
                    symlink_open = "@",
                },
                git = {
                    unstaged = "M",
                    staged = "A",
                    unmerged = "U",
                    renamed = "R",
                    untracked = "?",
                    deleted = "D",
                    ignored = "I",
                },
            },
        },
    },
    filters = {
        dotfiles = false,
    },
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
        enable = true,
        update_root = true,
    },
})

local telescope_actions = require("telescope.actions")

require("telescope").setup({
    defaults = {
        prompt_prefix = ">> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        multi_icon = "*",
        sorting_strategy = "ascending",
        layout_config = {
            prompt_position = "top",
        },
        borderchars = {
            "-",
            "|",
            "-",
            "|",
            "+",
            "+",
            "+",
            "+",
        },
        mappings = {
            i = {
                ["<C-j>"] = telescope_actions.move_selection_next,
                ["<C-k>"] = telescope_actions.move_selection_previous,
            },
            n = {
                ["j"] = telescope_actions.move_selection_next,
                ["k"] = telescope_actions.move_selection_previous,
            },
        },
    },
})
require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "^" },
        changedelete = { text = "~" },
        untracked = { text = "?" },
    },
    signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "^" },
        changedelete = { text = "~" },
    },
    signcolumn = true,
    numhl = true,
    linehl = false,
})
require("nvim-surround").setup({})
require("mini.pairs").setup({
    mappings = {
        ["<"] = { action = "open", pair = "<>" },
        [">"] = { action = "close", pair = "<>" },
    },
})
require("mini.comment").setup({
    mappings = {
        comment_visual = "<leader>c",
    },
})
-- local which_key = require("which-key")
--
-- which_key.setup({
--     delay = 200,
--     icons = {
--         mappings = false,
--         rules = false,
--         colors = false,
--         breadcrumb = ">",
--         separator = "->",
--         group = "+",
--         ellipsis = "...",
--         keys = {
--             Up = "UP",
--             Down = "DOWN",
--             Left = "LEFT",
--             Right = "RIGHT",
--             C = "C",
--             M = "M",
--             D = "D",
--             S = "S",
--             Esc = "ESC",
--             CR = "ENTER",
--             NL = "ENTER",
--             BS = "BS",
--             Space = "SPACE",
--             Tab = "TAB",
--             F1 = "F1",
--             F2 = "F2",
--             F3 = "F3",
--             F4 = "F4",
--             F5 = "F5",
--             F6 = "F6",
--             F7 = "F7",
--             F8 = "F8",
--             F9 = "F9",
--             F10 = "F10",
--             F11 = "F11",
--             F12 = "F12",
--         },
--     },
-- })
--
-- which_key.add({
--     { "<leader>f", group = "find" },
--     { "<leader>m", group = "markdown" },
-- })
