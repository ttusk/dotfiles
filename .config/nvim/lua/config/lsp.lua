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

local typescript_global_lib = ""
if vim.fn.executable("npm") == 1 then
    local npm_root = vim.fn.trim(vim.fn.system({ "npm", "root", "--global" }))
    if npm_root ~= "" then
        typescript_global_lib = npm_root .. "/typescript/lib"
    end
end
local function typescript_sdk(root_dir)
    if root_dir then
        local local_sdk = vim.fs.joinpath(root_dir, "node_modules", "typescript", "lib")
        if vim.uv.fs_stat(local_sdk) then
            return local_sdk
        end
    end

    return typescript_global_lib
end

vim.lsp.config["astro"] = {
    cmd = function(dispatchers, config)
        local cmd = "astro-ls"
        if config and config.root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules", ".bin", cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
    end,
    filetypes = { "astro" },
    root_markers = {
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
        ".git",
    },
    init_options = {
        typescript = {},
    },
    before_init = function(_, config)
        local tsdk = typescript_sdk(config.root_dir)
        if tsdk ~= "" then
            config.init_options.typescript.tsdk = tsdk
        end
    end,
}

local typescript_filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
}
local function typescript_language_server(root_dir)
    if root_dir then
        local local_cmd = vim.fs.joinpath(root_dir, "node_modules", ".bin", "typescript-language-server")
        if vim.fn.executable(local_cmd) == 1 then
            return local_cmd
        end
    end

    return vim.fn.exepath("typescript-language-server")
end

vim.lsp.config["ts_ls"] = {
    cmd = function(dispatchers, config)
        local cmd = typescript_language_server(config.root_dir)
        if cmd == "" then
            vim.notify("typescript-language-server is not installed", vim.log.levels.ERROR)
            return
        end
        return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
    end,
    filetypes = typescript_filetypes,
    root_markers = {
        { "tsconfig.json", "jsconfig.json" },
        "package.json",
        ".git",
    },
    init_options = {
        hostInfo = "neovim",
        tsserver = {
            fallbackPath = typescript_global_lib,
        },
        preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsWithSnippetText = true,
            jsxAttributeCompletionStyle = "braces",
        },
    },
}
local compose_schema = "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"
local github_workflow_schema = "https://json.schemastore.org/github-workflow.json"

vim.lsp.config["yamlls"] = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            validate = true,
            hover = true,
            completion = true,
            format = {
                enable = true,
            },
            schemaStore = {
                enable = true,
            },
            schemas = {
                [compose_schema] = {
                    "compose*.yml",
                    "compose*.yaml",
                    "docker-compose*.yml",
                    "docker-compose*.yaml",
                },
                [github_workflow_schema] = {
                    ".github/workflows/*.yml",
                    ".github/workflows/*.yaml",
                },
            },
        },
    },
}

vim.lsp.config["dockerls"] = {
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "dockerfile" },
    root_markers = {
        "Dockerfile",
        ".git",
    },
}

if vim.fn.executable("yaml-language-server") == 1 then
    vim.lsp.enable("yamlls")
end

if vim.fn.executable("docker-langserver") == 1 then
    vim.lsp.enable("dockerls")
end

local elixir_ls = vim.fn.exepath("elixir-ls")
vim.lsp.config["elixirls"] = {
    cmd = { elixir_ls },
    filetypes = { "elixir", "eelixir", "heex" },
    root_markers = {
        "mix.exs",
    },
    commands = {
        ["editor.action.triggerParameterHints"] = function()
            vim.lsp.buf.signature_help()
        end,
    },
}

if elixir_ls ~= "" and vim.fn.executable(elixir_ls) == 1 then
    vim.lsp.enable("elixirls")
end

vim.lsp.config["marksman"] = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = {
        ".marksman.toml",
        ".git",
    },
}

if vim.fn.executable("marksman") == 1 then
    vim.lsp.enable("marksman")
end

vim.lsp.config["texlab"] = {
    cmd = { "texlab" },
    filetypes = { "tex", "plaintex", "bib" },
    root_markers = {
        { ".latexmkrc", "latexmkrc", "texlab.toml", "main.tex", "Makefile" },
        ".git",
    },
    settings = {
        texlab = {
            build = {
                onSave = false,
            },
        },
    },
}

if vim.fn.executable("texlab") == 1 then
    vim.lsp.enable("texlab")
end

if vim.fn.executable("lua-language-server") == 1 then
    vim.lsp.enable("lua_ls")
end

if vim.fn.executable("typescript-language-server") == 1 then
    vim.lsp.enable("ts_ls")
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = typescript_filetypes,
    callback = function(args)
        local root_dir = vim.fs.root(args.buf, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
        if typescript_language_server(root_dir) ~= "" then
            vim.lsp.enable("ts_ls")
        end
    end,
})

vim.lsp.enable("astro")

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

local function format_completion_item(item)
    local label_details = item.labelDetails or {}
    local label_detail = label_details.detail or ""
    local abbr = item.label

    if label_detail ~= "" then
        abbr = abbr .. " " .. label_detail
    end

    local menu = label_details.description or item.detail or ""

    return {
        abbr = abbr .. " ",
        menu = menu == "" and menu or " " .. menu,
    }
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-completion", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client:is_stopped() then
            return
        end

        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
                convert = format_completion_item,
            })
        end
    end,
})
