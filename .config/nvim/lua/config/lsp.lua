vim.lsp.config["lua_ls"] = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        { ".luarc.json", ".luarc.jsonc" },
        ".git",
    },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
            },
        },
    },
}

vim.lsp.config["ts_ls"] = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
    },
    root_markers = {
        { "tsconfig.json", "jsconfig.json" },
        "package.json",
        ".git",
    },
    -- SolidJS uses TypeScript's standard TSX language service. A project's
    -- tsconfig.json should set jsxImportSource to "solid-js".
    init_options = {
        hostInfo = "neovim",
        preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsWithSnippetText = true,
            jsxAttributeCompletionStyle = "braces",
        },
    },
}

if vim.fn.executable("lua-language-server") == 1 then
    vim.lsp.enable("lua_ls")
end

if vim.fn.executable("typescript-language-server") == 1 then
    vim.lsp.enable("ts_ls")
end

vim.lsp.config["rust_analyzer"] = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = {
        "Cargo.toml",
        "rust-project.json",
        ".git",
    },
}

if vim.fn.executable("rust-analyzer") == 1 then
    vim.lsp.enable("rust_analyzer")
end
