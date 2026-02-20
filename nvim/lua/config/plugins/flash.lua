require("flash").setup({
    modes = {
        char = { enabled = false }, -- don't override f/t/F/T
    },
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
    require("flash").jump()
end, { desc = "Flash jump" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
end, { desc = "Flash treesitter" })
