
require('neo-tree').setup {
    filesystem = {
        follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
        },
        window = {
            position = 'right',
            width = 30,
        },
        filtered_items = { visible = true },
    },
}

vim.keymap.set("n", "<leader>e", function()
    local grug_far = require("grug-far")
    if grug_far.has_instance("gfar") then
        grug_far.get_instance("gfar"):close()
    end
    vim.cmd("Neotree toggle")
end, { desc = "NeoTree Toggle" })

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- avoid triggering when opening with a directory arg handled by neo-tree itself,
        -- or when reading from stdin
        if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 0 then
            vim.cmd("Neotree show")
        end
    end,
})

vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
        local transient_wins = {}
        local bufnames = {}
        local wins = vim.api.nvim_list_wins()
        local local_grug = require('grug-far')
        for _, w in ipairs(wins) do
            local bufid = vim.api.nvim_win_get_buf(w)
            local bufname = vim.api.nvim_buf_get_name(bufid)
            table.insert(bufnames, bufname)
            if (
                local_grug.is_instance_open(bufid) or
                bufname:match("neo%-tree") ~= nil or
                !vim.api.nvim_win_get_config(w).focusable
            )then
                table.insert(transient_wins, w)
            end
        end
        if #transient_wins == #wins - 1 then
            for _, w in ipairs(transient_wins) do
                vim.api.nvim_win_close(w, true)
            end
        end
    end,
})

