
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
    styles = {
        comments = { italic = false }, -- Disable italics in comments
    },
}

vim.pack.add({
  { src = "https://github.com/bluz71/vim-moonfly-colors", name = "moonfly" },
})


vim.pack.add({
  { src = "https://github.com/nuvic/flexoki-nvim", name = "flexoki" },
})


-- vim.cmd.colorscheme 'tokyonight-night'
-- vim.cmd.colorscheme 'moonfly'
vim.cmd.colorscheme 'flexoki'

vim.api.nvim_set_hl(0, "IblWhitespace", { fg = vim.api.nvim_get_hl(0, { name = "Whitespace" }).fg })

