vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file:find("/%.venv/") then
            return
        end

        -- Only format if ruff is actually attached to this buffer
        local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })
        if #clients == 0 then return end

        vim.lsp.buf.format({
            bufnr = args.buf,
            timeout_ms = 2000,
            filter = function(c)
                return c.name == "ruff"
            end,
        })
    end,
})
