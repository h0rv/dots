return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    nvent = "InsertEnter",
    config = function()
        require("copilot").setup({})
    end,
}
