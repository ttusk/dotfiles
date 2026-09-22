local lint = require("lint")

local markdown_linters = {}
if vim.fn.executable("markdownlint-cli2") == 1 then
    markdown_linters = { "markdownlint-cli2" }
elseif vim.fn.executable("markdownlint") == 1 then
    markdown_linters = { "markdownlint" }
end
local yaml_linters = {}
if vim.fn.executable("yamllint") == 1 then
    yaml_linters = { "yamllint" }
end

local dockerfile_linters = {}
if vim.fn.executable("hadolint") == 1 then
    dockerfile_linters = { "hadolint" }
end

lint.linters_by_ft = {
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
    markdown = markdown_linters,
    yaml = yaml_linters,
    dockerfile = dockerfile_linters,
}

local group = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        lint.try_lint(nil, { bufnr = args.buf })
    end,
})

vim.api.nvim_create_user_command("MarkdownLint", function()
    if #markdown_linters == 0 then
        vim.notify("No Markdown linter found; install markdownlint-cli2", vim.log.levels.WARN)
        return
    end

    lint.try_lint(nil, { bufnr = 0 })
end, { desc = "Lint current Markdown buffer" })

vim.api.nvim_create_user_command("Lint", function()
    lint.try_lint(nil, { bufnr = 0 })
end, { desc = "Lint current buffer" })
