vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
    out_dir = "build",
    callback = 1,
    continuous = 1,
}
vim.g.vimtex_quickfix_mode = 0

local sioyek_executable = vim.fn.exepath("sioyek")
if sioyek_executable == "" then
    for _, app_path in ipairs({
        "/Applications/Sioyek.app/Contents/MacOS/sioyek",
        vim.fn.expand("~/Applications/Sioyek.app/Contents/MacOS/sioyek"),
    }) do
        if vim.fn.executable(app_path) == 1 then
            sioyek_executable = app_path
            break
        end
    end
end

if sioyek_executable ~= "" then
    vim.g.vimtex_view_method = "sioyek"
    vim.g.vimtex_view_sioyek_exe = sioyek_executable
else
    vim.g.vimtex_view_method = "general"
end

local group = vim.api.nvim_create_augroup("latex-maps", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "tex", "plaintex" },
    callback = function(args)
        local function map(lhs, rhs, description)
            vim.keymap.set("n", lhs, rhs, {
                buffer = args.buf,
                silent = true,
                desc = description,
            })
        end

        map("<leader>lc", "<cmd>VimtexCompile<cr>", "Toggle LaTeX compilation")
        map("<leader>lv", "<cmd>VimtexView<cr>", "View compiled LaTeX PDF")
        map("<leader>le", "<cmd>VimtexErrors<cr>", "Show LaTeX errors")
        map("<leader>lt", "<cmd>VimtexTocOpen<cr>", "Open LaTeX table of contents")
    end,
})
