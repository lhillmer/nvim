vim.pack.add({
    "https://github.com/folke/persistence.nvim",
})

require("persistence").setup({
    options = { "buffers", "curdir", "tabpages" },
})

-- restore last session for current directory on startup
vim.api.nvim_create_autocmd("VimEnter", {
    nested = true,
    callback = function()
        if vim.fn.argc() == 0 then
            require("persistence").load()
        end
    end,
})

-- optional keymaps
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end)

