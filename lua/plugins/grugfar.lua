
vim.pack.add { 'https://github.com/MagicDuck/grug-far.nvim' }
require('grug-far').setup({
    windowCreationCommand = [[
        let s:neotree_win = -1
        for w in range(1, winnr('$'))
            if getbufvar(winbufnr(w), '&filetype') ==# 'neo-tree'
                let s:neotree_win = w
            endif
        endfor
        if s:neotree_win != -1
            execute s:neotree_win . 'wincmd w'
            close
        endif
        botright vsplit
        vertical resize 60
    ]],
    keymaps = {
        swapEngine = false,
        openLocation = false,
        openNextLocation = false,
        openPrevLocation = false,
    },
    prefills = {
        flags = "-w",
    },
    startInInsertMode = false,
    folding = {
        enabled = true,
        foldlevel = 0,
    },
})

vim.keymap.set(
    'n',
    '<leader>ff',
    function()
        require('grug-far').open({
            prefills = { search = vim.fn.expand("<cword>") },
            transient = true,
            instanceName = "gfar",
        })
    end,
    { desc = '[F]ind current word [f]' }
)

vim.keymap.set(
    'n',
    '<leader>fl',
    function()
        local entry = require('grug-far').get_last_history_entry()
        opts = {
            prefills = { search = vim.fn.expand("<cword>") },
            transient = true,
            instanceName = "gfar",
        }
        if entry ~= nil then
            opts.prefills = entry
            opts.engine = entry.engine
            opts.replacementInterpreter = entry.replacementInterpreter
        end
        require('grug-far').open(opts)
    end,
    { desc = 'Open [l]ast search' }
)

