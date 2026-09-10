
require('neo-tree').setup {
    filesystem = {
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
        for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            table.insert(bufnames, bufname)
            if (
                bufname:match("neo%-tree") ~= nil or
                !vim.api.nvim_win_get_config(w).focusable
            )then
                table.insert(transient_wins, w)
            end
        end
        print(vim.inspect(transient_wins))
        print(vim.inspect(wins))
        print(vim.inspect(bufnames))
        if #transient_wins == #wins - 1 then
            for _, w in ipairs(transient_wins) do
                vim.api.nvim_win_close(w, true)
            end
        end
    end,
})

