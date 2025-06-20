return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "folke/lazydev.nvim",
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
        {
            "rachartier/tiny-inline-diagnostic.nvim",
            event = "LspAttach",
            priority = 1000,
            config = function()
                require('tiny-inline-diagnostic').setup({
                    preset = "minimal",
                })
            end
        },
    },
    config = function()
        local capabilities = require('blink.cmp').get_lsp_capabilities()

        require('lspconfig').lua_ls.setup { capabilities = capabilities }
        require("lspconfig").pylsp.setup { capabilities = capabilities }
        require("lspconfig").ruff.setup { capabilities = capabilities }
        require("lspconfig").gopls.setup { capabilities = capabilities }

        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                if not client then return end

                if client:supports_method('textDocument/formatting') then
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                        end
                    })
                end
            end,
        })
    end,
}
