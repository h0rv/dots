return {
    "olimorris/persisted.nvim",
    event = "BufReadPre",
    priority = 10000,
    lazy = false,
    opts = {
        autostart = true,

        use_git_branch = true, -- Include the git branch in the session file name?
        autoload = true,       -- Automatically load the session for the cwd on Neovim startup?

        telescope = { mappings = { change_branch = "<C-b>" } },
    }
}
