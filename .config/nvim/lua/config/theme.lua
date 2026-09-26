local opt = vim.opt

local function system_background()
    if vim.fn.has("macunix") == 1 or vim.fn.has("mac") == 1 then
        local style = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })

        if style:lower():match("dark") then
            return "dark"
        end
    end

    return "light"
end

opt.termguicolors = true

local background = system_background()
opt.background = background
vim.cmd.colorscheme("sunbather")

if background == "light" then
    local readable_yellow = "#5f4b00"
    local readable_yellow_background = "#d6b82c"

    for _, group in ipairs({
        "WarningMsg",
        "DiagnosticWarn",
        "DiagnosticSignWarn",
        "DiagnosticVirtualTextWarn",
        "DiffChange",
        "SyntasticWarningSign",
        "NeomakeWarningSign",
    }) do
        vim.api.nvim_set_hl(0, group, { fg = readable_yellow })
    end

    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
        sp = readable_yellow,
        undercurl = true,
    })
    vim.api.nvim_set_hl(0, "IncSearch", {
        bg = readable_yellow_background,
        fg = "#262626",
    })
    vim.api.nvim_set_hl(0, "SyntasticWarning", {
        bg = readable_yellow_background,
        fg = "#262626",
        bold = true,
    })
end

local telescope_palette = background == "light" and {
    surface = "#eeeeee",
    text = "#262626",
    border = "#a8a8a8",
    prompt = "#c30771",
    results = "#008ec4",
    preview = "#10a778",
    selection = "#b6d6fd",
    selection_text = "#262626",
} or {
    surface = "#121212",
    text = "#c6c6c6",
    border = "#767676",
    prompt = "#d75f87",
    results = "#008ec4",
    preview = "#5fd7a7",
    selection = "#d75f87",
    selection_text = "#000000",
}

local telescope_highlights = {
    TelescopeNormal = { bg = telescope_palette.surface, fg = telescope_palette.text },
    TelescopeBorder = { bg = telescope_palette.surface, fg = telescope_palette.border },
    TelescopePromptNormal = { bg = telescope_palette.surface, fg = telescope_palette.text },
    TelescopePromptBorder = { bg = telescope_palette.surface, fg = telescope_palette.prompt },
    TelescopePromptTitle = { bg = telescope_palette.surface, fg = telescope_palette.prompt, bold = true },
    TelescopeResultsNormal = { bg = telescope_palette.surface, fg = telescope_palette.text },
    TelescopeResultsBorder = { bg = telescope_palette.surface, fg = telescope_palette.results },
    TelescopeResultsTitle = { bg = telescope_palette.surface, fg = telescope_palette.results, bold = true },
    TelescopePreviewNormal = { bg = telescope_palette.surface, fg = telescope_palette.text },
    TelescopePreviewBorder = { bg = telescope_palette.surface, fg = telescope_palette.preview },
    TelescopePreviewTitle = { bg = telescope_palette.surface, fg = telescope_palette.preview, bold = true },
    TelescopeSelection = { bg = telescope_palette.selection, fg = telescope_palette.selection_text, bold = true },
    TelescopeSelectionCaret = {
        bg = telescope_palette.selection,
        fg = telescope_palette.prompt,
        bold = true,
    },
    TelescopeMatching = { fg = telescope_palette.prompt, bold = true },
    TelescopeMultiSelection = { fg = telescope_palette.preview, bold = true },
}

for group, highlights in pairs(telescope_highlights) do
    vim.api.nvim_set_hl(0, group, highlights)
end
