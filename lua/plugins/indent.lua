
vim.pack.add { 'https://github.com/NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {}

vim.pack.add {
    { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
}

