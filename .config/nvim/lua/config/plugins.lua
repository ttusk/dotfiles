vim.pack.add({
    {
        src = "https://github.com/maxmx03/solarized.nvim",
        name = "solarized",
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
                    default = "[D]",
                    open = "[O]",
                    empty = "[E]",
                    empty_open = "[O]",
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
    },
})
