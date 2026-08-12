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

if vim.fn.executable("lua-language-server") == 1 then
    vim.lsp.enable("lua_ls")
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
