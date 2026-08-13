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

local rust_analyzer = vim.fn.exepath("rust-analyzer")
if rust_analyzer == "" and vim.fn.executable("rustup") == 1 then
    rust_analyzer = vim.fn.trim(vim.fn.system("rustup which rust-analyzer"))
end

vim.lsp.config["rust_analyzer"] = {
    cmd = { rust_analyzer },
    filetypes = { "rust" },
    -- Tauri keeps this at src-tauri/Cargo.toml. Neovim searches upward
    -- from the Rust file, so the workspace root becomes src-tauri.
    root_markers = {
        "Cargo.toml",
        "rust-project.json",
    },
    workspace_required = true,
}

if rust_analyzer ~= "" and vim.fn.executable(rust_analyzer) == 1 then
    vim.lsp.enable("rust_analyzer")
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-completion", { clear = true }),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if client:supports_method("textDocument/completion") then
            -- Trigger completion while typing words, after `#`, and after
            -- the server's own punctuation triggers.
            local provider = assert(client.server_capabilities.completionProvider)
            local trigger_characters = { ["#"] = true }
            for _, character in ipairs(provider.triggerCharacters or {}) do
                trigger_characters[character] = true
            end
            for character in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
                trigger_characters[character] = true
            end
            provider.triggerCharacters = vim.tbl_keys(trigger_characters)

            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
            })
        end
    end,
})
