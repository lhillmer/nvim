
vim.pack.add { 'https://github.com/folke/which-key.nvim' }
    require('which-key').setup {
    delay = 250,
    icons = { mappings = vim.g.have_nerd_font },
    -- Document existing key chains
    spec = {
        { '<leader>f', group = '[F]ind', mode = { 'n', 'v' } },
        { '<leader>h', group = '[H] git actions', mode = { 'n', 'v' } },
        { 'g', group = 'LSP Actions', mode = { 'n' } },
    },
}

