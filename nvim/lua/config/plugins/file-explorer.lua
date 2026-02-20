require("neo-tree").setup({
    close_if_last_window = true,
    popup_border_style = "rounded",

    window = {
        width = 34,
        mappings = {
            ["l"] = "open",
            ["h"] = "close_node",
            ["H"] = "toggle_hidden",
        },
    },

    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            never_show = { ".git", ".DS_Store" },
        },
        -- OFF: cursor stays where you left it in the tree
        -- Use <leader>o to reveal on demand instead
        follow_current_file = {
            enabled = false,
        },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
    },

    -- Prevent the tree from jumping to the top when you open a file
    -- This is what actually causes the "cursor reset" feeling
    event_handlers = {
        {
            event = "file_opened",
            handler = function()
                -- do nothing — suppress the default behavior
                -- that resets tree scroll position on open
            end,
        },
    },

    default_component_configs = {
        git_status = {
            symbols = {
                added     = "✚",
                modified  = "",
                deleted   = "✖",
                renamed   = "󰁕",
                untracked = "",
                ignored   = "",
                unstaged  = "󰄱",
                staged    = "",
                conflict  = "",
            },
        },
    },
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>",  { desc = "Explorer: toggle" })
vim.keymap.set("n", "<leader>o", "<cmd>Neotree reveal<CR>",  { desc = "Explorer: reveal file" })

-- Yazi
-- require("yazi").setup({
--     open_for_directories = false,
--     keymaps = {
--         show_help = "<f1>",
--     },
-- })
-- -- Yazi: toggle (resume last session by default)
-- vim.keymap.set("n", "<leader>e", "<cmd>Yazi toggle<CR>", { desc = "Explorer: yazi (resume/toggle)" })
-- 
-- -- Optional: open in cwd (fresh)
-- vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<CR>", { desc = "Explorer: yazi (cwd)" })
-- 
-- -- Optional: open at current file (fresh)
-- vim.keymap.set({ "n", "v" }, "<leader>o", "<cmd>Yazi<CR>", { desc = "Explorer: yazi (at file)" })
