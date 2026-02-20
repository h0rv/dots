-- Python stack: basedpyright (types/navigation) + ruff (lint/format)
vim.lsp.config("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyrightconfig.json", ".venv", ".git" },
    settings = {
        python = {
            pythonPath = ".venv/bin/python",
        },
        basedpyright = {
            disableOrganizeImports = true,        -- Ruff handles formatting
            analysis = {
                diagnosticMode = "openFilesOnly", -- Monorepo-friendly
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                stubPath = "stubs",
            },
        },
    },
})

vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { ".venv", ".git" },
})

-- TypeScript/JavaScript/React: typescript-language-server
vim.lsp.config("typescript", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                autoImports = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                autoImports = true,
            },
        },
    },
})

vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git" },
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.fn.stdpath("config"),
                    vim.fn.stdpath("data"),
                },
                checkThirdParty = false,
            },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
        },
    },
})

vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
    settings = {
        json = {
            validate = { enable = true },
            format = { enable = true },
        },
    },
})

vim.lsp.config("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yml" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            validate = { enable = true },
            format = { enable = true },
            hover = true,
            completion = true,
        },
    },
})

vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".git" },
})

vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
            },

            checkOnSave = true,
            check = {
                command = "clippy",
            },

            procMacro = { enable = true },

            formatting = {
                enable = true, -- rustfmt
            },

            inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closureReturnTypeHints = { enable = "always" },
                lifetimeElisionHints = { enable = "always", useParameterNames = true },
                parameterHints = { enable = true },
                reborrowHints = { enable = "always" },
                typeHints = { enable = true },
            },
        },
    },
})

-- Elixir: elixir-ls
vim.lsp.config("elixirls", {
    cmd = { "elixir-ls" },
    filetypes = { "elixir", "heex" },
    root_markers = { "mix.exs", ".git" },
    settings = {
        elixirLS = {
            dialyzerEnabled = true,
            fetchDeps = false,
            enableTestLenses = true,
            suggestSpecs = true,
        },
    },
})

vim.lsp.enable({ "basedpyright", "ruff", "typescript", "lua_ls", "jsonls", "yamlls", "taplo", "rust_analyzer", "elixirls", })

vim.diagnostic.config({
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, prefix = "●" },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        -- Ruff docs recommend disabling hover to avoid conflicts with basedpyright
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end

        -- Extend trigger characters for completion on every keystroke
        if client.server_capabilities.completionProvider then
            local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
            for char in string.gmatch("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", ".") do
                if not vim.tbl_contains(triggers, char) then
                    table.insert(triggers, char)
                end
            end
            client.server_capabilities.completionProvider.triggerCharacters = triggers
        end

        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

        local opts = { buffer = bufnr, silent = true }

        vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, vim.tbl_extend("force", opts, { desc = "Implementation" }))
        vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, vim.tbl_extend("force", opts, { desc = "Type definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { desc = "Code action" }))

        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, vim.tbl_extend("force", opts, { desc = "Prev diagnostic" }))
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "<leader>dd", function() Snacks.picker.diagnostics() end, vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
        vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist,
            vim.tbl_extend("force", opts, { desc = "Diagnostics -> quickfix" }))

        -- Vscode-like goto def
        vim.o.mouse = "a"
        vim.keymap.set("n", "<C-LeftMouse>", function()
            vim.lsp.buf.definition()
        end, { desc = "LSP: go to definition (Ctrl+Click)" })
        vim.keymap.set("n", "<2-LeftMouse>", vim.lsp.buf.definition,
            { desc = "LSP: go to definition (double click)" })

        pcall(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end)
    end,
})

vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    end
    return "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-p>"
    end
    return "<S-Tab>"
end, { expr = true, silent = true })
