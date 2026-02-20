require("persistence").setup({})

local set = vim.keymap.set

set("n", "<leader>qs", function()
    require("persistence").load()
end, { desc = "Restore session" })

set("n", "<leader>qS", function()
    require("persistence").select()
end, { desc = "Select session" })

set("n", "<leader>qd", function()
    require("persistence").stop()
end, { desc = "Stop auto-save" })
