
vim.pack.add { 'https://github.com/famiu/bufdelete.nvim' }

vim.keymap.set("n", "<leader>bc", "<Cmd>Bdelete<CR>")

vim.keymap.set("n", "<leader>bd", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ft = vim.bo[buf].filetype
        if ft ~= "neo-tree" and ft ~= "grug-far" then
            vim.api.nvim_buf_delete(buf, { force = false })
        end
    end
end, { desc = "Close all buffers except neo-tree/grug-far" })

vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/akinsho/bufferline.nvim",
})

vim.opt.termguicolors = true

require("bufferline").setup({
    options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = true,
    },
})


