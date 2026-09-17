vim.g.copilot_no_tab_map = true

-- Keep LazyGit's floating modal in the same ASCII style as Telescope.
vim.g.lazygit_floating_window_scaling_factor = 0.9
vim.g.lazygit_floating_window_border_chars = { "-", "|", "-", "|", "+", "+", "+", "+" }

vim.pack.add({
    {
        src = "https://github.com/ttusk/colorscheme.tdsotm",
        name = "tdsotm",
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
        src = "https://github.com/kdheepak/lazygit.nvim",
        name = "lazygit",
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
    {
        src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        name = "render-markdown",
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
require("mini.icons").setup({
    style = "glyph",
})
local mini_icons = require("mini.icons")
local function filetype_icon()
    local filetype = vim.bo.filetype
    if filetype == "" then
        return ""
    end
    return mini_icons.get("filetype", filetype)
end
local function filetype_icon_color()
    local filetype = vim.bo.filetype
    if filetype == "" then
        return nil
    end
    local _, highlight = mini_icons.get("filetype", filetype)
    return highlight
end

require("lualine").setup({
    options = {
        icons_enabled = false,
        theme = "tdsotm",
        component_separators = "|",
        section_separators = "",
        globalstatus = false,
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            {
                function() return "λ" end,
                color = function()
                    return {
                        fg = vim.o.background == "dark" and "#F25F72" or "#CC102D",
                        gui = "bold",
                    }
                end,
                padding = { left = 1, right = 0 },
                separator = "",
            },
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
            {
                filetype_icon,
                color = filetype_icon_color,
            },
            {
                "lsp_status",
                ignore_lsp = { "GitHub Copilot" },
                icon = "",
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
        lualine_x = {
            {
                filetype_icon,
                color = filetype_icon_color,
            },
            "location",
        },
        lualine_y = {},
        lualine_z = {},
    },
    extensions = { "nvim-tree", "quickfix", "man" },
})
require("mini.tabline").setup({
    show_icons = true,
})
local treesitter_filetypes = {
    "astro",
    "bash",
    "css",
    "eelixir",
    "elixir",
    "heex",
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
    "eex",
    "elixir",
    "heex",
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
    "yaml",
})
require("render-markdown").setup({
    render_modes = { "n", "c", "t" },
    latex = {
        enabled = false,
    },
    completions = {
        lsp = {
            enabled = true,
        },
    },
    heading = {
        sign = false,
        icons = { "H1 ", "H2 ", "H3 ", "H4 ", "H5 ", "H6 " },
        position = "inline",
        width = "block",
    },
    code = {
        sign = false,
        language_icon = false,
        language_info = false,
        width = "block",
        border = "thin",
        language_border = "-",
        above = "-",
        below = "-",
    },
    bullet = {
        icons = { "-", "*", "+" },
    },
    checkbox = {
        unchecked = {
            icon = "[ ]",
        },
        checked = {
            icon = "[x]",
        },
        custom = {
            todo = {
                rendered = "[-]",
            },
        },
    },
    quote = {
        icon = ">",
    },
    dash = {
        icon = "-",
    },
    pipe_table = {
        border = { "+", "+", "+", "+", "+", "+", "+", "+", "+", "|", "-" },
        alignment_indicator = "-",
    },
    link = {
        enabled = false,
    },
    win_options = {
        conceallevel = {
            default = 2,
            rendered = 3,
        },
        concealcursor = {
            default = "",
            rendered = "",
        },
    },
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
        eelixir = { "mix" },
        elixir = { "mix" },
        heex = { "mix" },
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
