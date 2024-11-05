local M = {}

local cmd_buf
local cmd_win

local function print_cmd(str)
    vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { str .. ' ' })
    vim.api.nvim_win_set_cursor(cmd_win, { 1, #str })
end

function M.prev_cmd_history()
    local str
    if #_G.jir_calc_cmd_history > 0 then
        str = _G.jir_calc_cmd_history[#_G.jir_calc_cmd_history - _G.jir_calc_cmd_history_indx]
        if _G.jir_calc_cmd_history_indx < #_G.jir_calc_cmd_history - 1 then
            _G.jir_calc_cmd_history_indx = _G.jir_calc_cmd_history_indx + 1
        end
        print_cmd(str)
    end
end

function M.next_cmd_history()
    local str
    if #_G.jir_calc_cmd_history > 0 then
        if _G.jir_calc_cmd_history_indx > 0 then
            _G.jir_calc_cmd_history_indx = _G.jir_calc_cmd_history_indx - 1
            str = _G.jir_calc_cmd_history[#_G.jir_calc_cmd_history - _G.jir_calc_cmd_history_indx]
        else
            str = '> '
        end
        print_cmd(str)
    end
end

local function print_history(history, main_buf, win_height)
    if #history > win_height - 1 then
        history = vim.list_slice(history, #history - win_height + 2, #history)
    end

    if #history < win_height - 1 then
        vim.api.nvim_buf_set_lines(main_buf, 0, -1, false, vim.fn['repeat']({' '}, win_height - #history))
    end

    local current_line_count = vim.api.nvim_buf_line_count(main_buf)
    for _, str in ipairs(history) do
        vim.api.nvim_buf_set_lines(main_buf, current_line_count, current_line_count, false, { str })
        current_line_count = current_line_count + 1
    end
end

-- Function to open a floating window
function M.open_window()
    local width = vim.api.nvim_get_option('columns')
    local height = vim.api.nvim_get_option('lines')
    local win_height = math.ceil(height * 0.3)
    local win_width = math.ceil(width * 0.8)
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)

    _G.jir_calc_cmd_history_indx = 0
    -- Pre-fill the main buffer with empty lines to position the first result at the bottom
    local main_buf = vim.api.nvim_create_buf(false, true)
    print_history(_G.jir_calc_result_history, main_buf, win_height)
    local title = ' Jir Calculator '
    local opts = {
        style = 'minimal',
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = 'rounded',
        title = title,
        title_pos = 'center',
    }

    local win = vim.api.nvim_open_win(main_buf, true, opts)
    vim.api.nvim_buf_set_option(main_buf, 'bufhidden', 'wipe')

    -- Create a command input area at the bottom
    cmd_buf = vim.api.nvim_create_buf(false, true)
    local cmd_opts = {
        style = 'minimal',
        relative = 'editor',
        width = win_width,
        height = 1,
        row = row + win_height + 2,
        col = col,
        border = 'rounded',
    }
    cmd_win = vim.api.nvim_open_win(cmd_buf, true, cmd_opts)
    vim.api.nvim_buf_set_option(cmd_buf, 'bufhidden', 'wipe')

    -- Switch to insert mode in the commad input window
    vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { '> ' })
    vim.api.nvim_set_current_win(cmd_win)
    vim.api.nvim_command('startinsert')
    vim.api.nvim_win_set_cursor(cmd_win, { 1, 3 }) -- Position cursor after '> '

    -- Set initial content of the command buffer
    vim.api.nvim_buf_set_keymap(cmd_buf,  'i', '<CR>',   "<cmd>lua require'jir_calc.command'.handle_command(" .. win .. ")<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(main_buf, 'i', '<Esc>',  "<cmd>lua require'jir_calc.window'.close_windows()<CR><ESC>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(main_buf, 'n', '<Esc>',  "<cmd>lua require'jir_calc.window'.close_windows()<CR><ESC>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(cmd_buf,  'i', '<Esc>',  "<cmd>lua require'jir_calc.window'.close_windows()<CR><ESC>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(cmd_buf,  'n', '<Esc>',  "<cmd>lua require'jir_calc.window'.close_windows()<CR><ESC>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(cmd_buf,  'i', '<Up>',   "<cmd>lua require'jir_calc.window'.prev_cmd_history()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(cmd_buf,  'i', '<Down>', "<cmd>lua require'jir_calc.window'.next_cmd_history()<CR>", { noremap = true, silent = true })

    return win, cmd_win
end

-- Function to close both floating windows
function M.close_windows()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name == '' then
            vim.api.nvim_win_close(win, true)
        end
    end
end

return M



