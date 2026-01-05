vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file:find("/%.venv/") then
            return
        end

        vim.lsp.buf.format({
            bufnr = args.buf,
            timeout_ms = 2000,
            filter = function(c)
                return c.name == "ruff"
            end,
        })
    end,
})
