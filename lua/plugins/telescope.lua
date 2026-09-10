-- [[ Fuzzy Finder (files, lsp, etc) ]]
---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, 'https://github.com/nvim-telescope/telescope-fzf-native.nvim') end
vim.pack.add(telescope_plugins)

-- See `:help telescope` and `:help telescope.setup()`
-- test u asdf i
require('telescope').setup {
    extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fF', builtin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<C-p>', builtin.find_files)
vim.keymap.set({ 'n', 'v' }, '<leader>fc', builtin.grep_string, { desc = '[F]ind [c]urrent word' })
-- vim.keymap.set('n', '<leader>ff', builtin.live_grep, { desc = '[F]ind by grep [d]' })
vim.keymap.set('n', '<leader>fb', builtin.buffers , { desc = '[F]ind [b]uffers' })
vim.keymap.set('n', '<leader>fi', builtin.diagnostics, { desc = '[F]ind d[i]agnostics' })
vim.keymap.set('n', '<leader>f.', builtin.resume, { desc = '[F]ind [R]esume' })
vim.keymap.set('n', '<leader>fC', builtin.commands, { desc = '[F]ind [C]ommands' })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
        local buf = event.buf

        vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
        vim.keymap.set('n', 'gi', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
        vim.keymap.set('n', 'g ', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
        vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        -- TODO: this seems useless, would rather just not hit it on accident
        -- but keeping it here documented in case I change my mind later
        -- vim.keymap.set('n', 'gf', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
    end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

