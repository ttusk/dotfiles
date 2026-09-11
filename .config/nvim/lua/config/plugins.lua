vim.g.copilot_no_tab_map = true
vim.pack.add({
    {
        src = "https://github.com/nikolvs/vim-sunbather",
        name = "sunbather",
    },
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
    {
        src = "https://github.com/mfussenegger/nvim-lint",
        name = "nvim-lint",
    },
    {
        src = "https://github.com/stevearc/conform.nvim",
        name = "conform",
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
    {
        src = "https://github.com/nvim-lualine/lualine.nvim",
        name = "lualine",
    },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "nvim-treesitter",
    },
    {
        src = "https://github.com/github/copilot.vim",
        name = "copilot",
    },
    -- {
    --     src = "https://github.com/folke/which-key.nvim",
    --     name = "which-key",
    -- },
    {
        src = "https://github.com/3rd/image.nvim",
        name = "image",
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
        git_ignored = true,
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
    signcolumn = false,
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
require("lualine").setup({
    options = {
        icons_enabled = false,
        theme = "auto",
        component_separators = "|",
        section_separators = "",
        globalstatus = false,
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            "branch",
            { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
            {
                "diagnostics",
                symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
            },
        },
        lualine_c = {
            {
                "filename",
                path = 0,
                symbols = { modified = "[+]", readonly = "[RO]", unnamed = "[No Name]" },
            },
        },
        lualine_x = {
            "filetype",
            {
                "lsp_status",
                symbols = {
                    spinner = { "-", "\\", "|", "/" },
                    done = "OK",
                    separator = " ",
                },
            },
            "selectioncount",
        },
        lualine_y = { "location" },
        lualine_z = { "progress" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "filetype", "location" },
        lualine_y = {},
        lualine_z = {},
    },
    extensions = { "nvim-tree", "quickfix", "man" },
})
local treesitter_filetypes = {
    "astro",
    "bash",
    "css",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "rust",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
}

require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})
require("nvim-treesitter").install({
    "astro",
    "bash",
    "css",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "rust",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
})
local treesitter_group = vim.api.nvim_create_augroup("treesitter-start", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = treesitter_group,
    pattern = treesitter_filetypes,
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
require("conform").setup({
    formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        markdown = { "prettier" },
    },
})
require("image").setup({
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
        },
    },
    max_width_window_percentage = 50,
    max_height_window_percentage = 50,
    tmux_show_only_in_active_window = true,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.ico" },
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
