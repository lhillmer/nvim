-- [[ Autocomplete Engine ]]
vim.pack.add { { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' } }
    require('blink.cmp').setup {
    keymap = {
        -- See `:help blink-cmp-config-keymap` for defining your own keymap
        preset = 'super-tab',
    },

    appearance = {
        nerd_font_variant = 'mono',
    },

    completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 250 },
    },

    sources = {
        default = { 'lsp', 'path'},
    },

    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
}

