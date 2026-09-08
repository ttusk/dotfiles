local lint = require("lint")

lint.linters_by_ft = {
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
    markdown = { "markdownlint-cli2" },
}

local group = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        lint.try_lint(nil, { bufnr = args.buf })
    end,
})

vim.api.nvim_create_user_command("MarkdownLint", function()
    lint.try_lint(nil, { bufnr = 0 })
end, { desc = "Lint current Markdown buffer" })
