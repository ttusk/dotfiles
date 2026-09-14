vim.g.markdown_folding = 1

local function has_spell_dictionary(language)
    return #vim.fn.globpath(vim.o.runtimepath, "spell/" .. language .. "*.spl", false, true) > 0
end

local has_portuguese_spell = has_spell_dictionary("pt")
local spell_languages = { "en_us" }
if has_portuguese_spell then
    table.insert(spell_languages, 1, "pt")
end
local spelllang = table.concat(spell_languages, ",")

local group = vim.api.nvim_create_augroup("markdown-workflow", { clear = true })

local function map(buffer, mode, lhs, rhs, description)
    vim.keymap.set(mode, lhs, rhs, {
        buffer = buffer,
        silent = true,
        desc = description,
    })
end

local function toggle_spell()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    local state = vim.opt_local.spell:get() and "on" or "off"
    vim.notify("Markdown spell checking: " .. state .. " (" .. spelllang .. ")")
end

local function toggle_checkboxes(buffer, start_line, end_line)
    local lines = vim.api.nvim_buf_get_lines(buffer, start_line - 1, end_line, false)
    local changed = false

    for index, line in ipairs(lines) do
        local prefix, state, suffix = line:match("^(%s*[-+*]%s+)%[([ xX%-])%](.*)$")
        if not prefix then
            prefix, state, suffix = line:match("^(%s*%d+[.)]%s+)%[([ xX%-])%](.*)$")
        end

        if prefix then
            local next_state = state:lower() == "x" and " " or "x"
            lines[index] = prefix .. "[" .. next_state .. "]" .. suffix
            changed = true
        end
    end

    if changed then
        vim.api.nvim_buf_set_lines(buffer, start_line - 1, end_line, false, lines)
    else
        vim.notify("No Markdown checkbox found in the selection", vim.log.levels.INFO)
    end
end

local function toggle_checkbox()
    local buffer = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local start_line
    local end_line

    if mode == "n" then
        start_line = vim.api.nvim_win_get_cursor(0)[1]
        end_line = start_line
    else
        local visual_start = vim.fn.getpos("v")[2]
        local visual_end = vim.api.nvim_win_get_cursor(0)[1]
        if visual_start == 0 then
            return
        end
        start_line = math.min(visual_start, visual_end)
        end_line = math.max(visual_start, visual_end)
    end

    toggle_checkboxes(buffer, start_line, end_line)
end

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(args)
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.breakindentopt = ""
        vim.opt_local.showbreak = "  "
        vim.opt_local.conceallevel = 2
        vim.opt_local.spelllang = spelllang
        vim.opt_local.spell = has_portuguese_spell
        vim.opt_local.foldlevel = 99
        vim.opt_local.formatoptions:append("jro")

        map(args.buf, "n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", "Toggle Markdown rendering")
        map(args.buf, "n", "<leader>mp", "<cmd>RenderMarkdown preview<cr>", "Open rendered Markdown preview")
        map(args.buf, "n", "<leader>mf", function()
            require("conform").format({ async = true, lsp_format = "fallback" })
        end, "Format Markdown buffer")
        map(args.buf, "n", "<leader>ml", "<cmd>MarkdownLint<cr>", "Lint Markdown buffer")
        map(args.buf, "n", "<leader>ms", toggle_spell, "Toggle Markdown spell checking")
        map(args.buf, { "n", "x" }, "<leader>mc", toggle_checkbox, "Toggle Markdown checkbox")
    end,
})
