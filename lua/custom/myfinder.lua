-- filtered_finder.lua
-- Telescope picker with three fields: main prompt, include globs, exclude globs.
-- <Tab>/<S-Tab> cycle focus between them. Docked at the bottom, stays open
-- until explicitly closed with q / <C-q>.
-- Requires: telescope.nvim, fd (fdfind on some distros)

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

local M = {}

local function build_cmd(include_patterns, exclude_patterns)
    local cmd = { "fd", "--type", "f", "--color", "never" }

    for pat in (include_patterns or ""):gmatch("[^,]+") do
        pat = vim.trim(pat)
        if pat ~= "" then
            table.insert(cmd, "--glob")
            table.insert(cmd, pat)
        end
    end

    for pat in (exclude_patterns or ""):gmatch("[^,]+") do
        pat = vim.trim(pat)
        if pat ~= "" then
            table.insert(cmd, "--exclude")
            table.insert(cmd, pat)
        end
    end

    return cmd
end

-- Create a small scratch buffer + floating window used as a text field.
local function make_field_win(opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        row = opts.row,
        col = opts.col,
        width = opts.width,
        height = 1,
        style = "minimal",
        border = "single",
        title = opts.title,
        title_pos = "center",
        zindex = 210, -- above telescope's own floats
    })

    vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:TelescopeBorder"
    return buf, win
end

local function get_buf_text(buf)
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, 1, false), "")
end

local function focus(win)
    vim.api.nvim_set_current_win(win)
    vim.cmd("startinsert!")
end

function M.filtered_find_files(opts)
    opts = opts or {}
    local state = { include = "", exclude = "" }

    local picker = pickers.new(opts, {
        prompt_title = "Filtered Files  (Tab: cycle fields, C-q/q: close)",
        finder = finders.new_oneshot_job(build_cmd("", ""), opts),
        sorter = conf.file_sorter(opts),
        previewer = conf.file_previewer(opts),

        layout_strategy = "bottom_pane",
        layout_config = {
            height = 18,
            prompt_position = "top",
        },

        attach_mappings = function(_, map)
            -- Open selection but keep the picker open.
            local action_state = require("telescope.actions.state")
            local open_without_closing = function()
                local entry = action_state.get_selected_entry()
                if not entry then
                    return
                end
                vim.cmd("wincmd p")
                vim.cmd("edit " .. vim.fn.fnameescape(entry.value))
                vim.cmd("wincmd p")
            end
            actions.select_default:replace(open_without_closing)
            return true
        end,
    })

    picker:find()

    local prompt_win = picker.prompt_win
    local prompt_buf = picker.prompt_bufnr
    local results_win = picker.results_win

    -- Figure out the top edge of telescope's own layout so the two extra
    -- fields sit directly above it.
    local p_cfg = vim.api.nvim_win_get_config(prompt_win)
    local r_cfg = vim.api.nvim_win_get_config(results_win)
    local top_row = math.min(p_cfg.row, r_cfg.row)
    local total_width = p_cfg.width
    local col = p_cfg.col

    local field_row = top_row - 3 -- each field window is 3 rows tall (border + 1 line)
    local half_width = math.floor(total_width / 2) - 1

    local include_buf, include_win = make_field_win({
        row = field_row,
        col = col,
        width = half_width,
        title = " Include (comma-separated globs) ",
    })

    local exclude_buf, exclude_win = make_field_win({
        row = field_row,
        col = col + half_width + 2,
        width = total_width - half_width - 2,
        title = " Exclude (comma-separated globs) ",
    })

    local function refresh()
        local cmd = build_cmd(state.include, state.exclude)
        picker:refresh(finders.new_oneshot_job(cmd, opts), { reset_prompt = false })
    end

    local function on_field_change(buf, key)
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            buffer = buf,
            callback = function()
                state[key] = get_buf_text(buf)
                refresh()
            end,
        })
    end

    on_field_change(include_buf, "include")
    on_field_change(exclude_buf, "exclude")

    -- Close everything together, however the prompt window goes away.
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(prompt_win),
        once = true,
        callback = function()
            pcall(vim.api.nvim_win_close, include_win, true)
            pcall(vim.api.nvim_win_close, exclude_win, true)
        end,
    })

    local function close_all()
        pcall(vim.api.nvim_win_close, prompt_win, true)
    end

    -- Tab cycling: prompt -> include -> exclude -> prompt
    vim.keymap.set({ "i", "n" }, "<Tab>", function() focus(include_win) end, { buffer = prompt_buf })
    vim.keymap.set({ "i", "n" }, "<Tab>", function() focus(exclude_win) end, { buffer = include_buf })
    vim.keymap.set({ "i", "n" }, "<Tab>", function() focus(prompt_win) end, { buffer = exclude_buf })

    -- Reverse cycling: prompt -> exclude -> include -> prompt
    vim.keymap.set({ "i", "n" }, "<S-Tab>", function() focus(exclude_win) end, { buffer = prompt_buf })
    vim.keymap.set({ "i", "n" }, "<S-Tab>", function() focus(prompt_buf) end, { buffer = include_buf })
    vim.keymap.set({ "i", "n" }, "<S-Tab>", function() focus(include_win) end, { buffer = exclude_buf })

    -- <CR> in a field: commit and hop back to the prompt.
    vim.keymap.set({ "i", "n" }, "<CR>", function() focus(prompt_win) end, { buffer = include_buf })
    vim.keymap.set({ "i", "n" }, "<CR>", function() focus(prompt_win) end, { buffer = exclude_buf })

    -- Explicit close from any of the three windows.
    vim.keymap.set({ "i", "n" }, "<C-q>", close_all, { buffer = prompt_buf })
    vim.keymap.set("n", "q", close_all, { buffer = prompt_buf })
    for _, buf in ipairs({ include_buf, exclude_buf }) do
        vim.keymap.set({ "i", "n" }, "<C-q>", close_all, { buffer = buf })
        vim.keymap.set("n", "q", close_all, { buffer = buf })
    end
end

vim.keymap.set("n", "<leader>fl", function()
    M.filtered_find_files()
end)

return M

