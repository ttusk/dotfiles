local lint = require("lint")

lint.linters_by_ft = {
    markdown = { "markdownlint-cli2" },
}

local group = vim.api.nvim_create_augroup("markdown-lint", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        if vim.bo[args.buf].filetype == "markdown" then
            lint.try_lint(nil, { bufnr = args.buf })
        end
    end,
})

vim.api.nvim_create_user_command("MarkdownLint", function()
    lint.try_lint(nil, { bufnr = 0 })
end, { desc = "Lint current Markdown buffer" })
