-- [[ Core Neovim settings, leaders, options ]]
-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.wrap = false


-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', space = '·', lead = '·' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 15
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
vim.o.confirm = true


-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', ',', 'za', { noremap = true, silent = true })

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float {
                bufnr = bufnr,
                scope = 'cursor',
                focus = false,
            }
        end,
    },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

do
    -- [[ Intro to `vim.pack` ]]
    --  See `:help vim.pack`, `:help vim.pack-examples` or the
    --  To inspect plugin state and pending updates, run
    --    :lua vim.pack.update(nil, { offline = true })
    --  To update plugins, run
    --    :lua vim.pack.update()

    -- Helper function for plugins that need to run commands to finish configuring
    local function run_build(name, cmd, cwd)
        local result = vim.system(cmd, { cwd = cwd }):wait()
        if result.code ~= 0 then
            local stderr = result.stderr or ''
            local stdout = result.stdout or ''
            local output = stderr ~= '' and stderr or stdout
            if output == '' then output = 'No output from build command.' end
            vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
        end
    end

    -- This autocommand runs after a plugin is installed or updated and
    --  runs the appropriate build command for that plugin if necessary.
    -- See `:help vim.pack-events`
    vim.api.nvim_create_autocmd('PackChanged', {
        -- TODO: make this not hard coded to each name. Can I add an extra hook to PackChanged for each plugin?
        callback = function(ev)
            local name = ev.data.spec.name
            local kind = ev.data.kind
            if kind ~= 'install' and kind ~= 'update' then return end

            if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
                run_build(name, { 'make' }, ev.data.path)
                return
            end

            if name == 'LuaSnip' then
                if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
                return
            end

            if name == 'nvim-treesitter' then
                if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
                vim.cmd 'TSUpdate'
                return
            end
        end,
    })
end

require("plugins.gitsigns")

require("plugins.whichkey")
require("plugins.colorscheme")
require("plugins.todocomments")
require("plugins.mini")

require("plugins.telescope")

require("plugins.blink")
require("plugins.mason")

require("plugins.treesitter")

require("plugins.bufferline")
require("plugins.indent")
require("plugins.neotree")
require("plugins.persistence")

require("plugins.grugfar")

