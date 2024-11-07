local M = {}
local jir_calc = require('jir_calc.jir_calc_setup')

local cmd_buf
local cmd_win
local help_buf
local help_win
local main_buf
local main_win

local help = {
    '=b        : to get binary result 5 = 0b101',
    '=h        : to get hex result (or =x) 12 = 0xC',
    '0b prefix : send binary by using prefix 0b - 0b0111 = 7',
    '0x prefix : send hex by using prefix 0x    - 0x0F = 15',
    '<,> signs : shift n m times - 1<4 = 16',
    'ANS       : use or ans to get last result into calculation',
    '\\<Var>    : store value in Memory (any string after backslash)',
    '\\MC       : clears memory',
    '\\MR       : recalls memory',
    '_         : pad with underscore as it will be ignored',
    '%         : modulo %',
    'pi        : The value of π (pi).',
    'sin(x)    : Returns the sine of x (x is in radians). etc.',
    'asin(x)   : Returns the arcsine of x (in radians). etc.',
    'sqrt(x)   : Returns the square root of x.',
    'abs(x)    : Returns the absolute value of x.',
    'exp(x)    : Returns the value of e^x.',
    'log(x)    : Returns the natural logarithm of x.',
    'log10(x)  : Returns the base-10 logarithm of x.',
    'log(x, base): Returns the logarithm of x with the specified base.',
    'random()  : Returns a random number between 0 and 1.',
    'random(n) : Returns a random integer between 1 and n.',
    'random(m, n): Returns a random integer between m and n.',
}

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

local function print_help(help_buf, win_height)
    local current_line_count = 0

    for _, str in ipairs(help) do
        if current_line_count > win_height - 2 then
            break
        end
        vim.api.nvim_buf_set_lines(help_buf, current_line_count, current_line_count, false, { str })
        current_line_count = current_line_count + 1
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
    local width
    if jir_calc.settings.enable_help_window then
        width = math.ceil(vim.api.nvim_get_option_value('columns', { }) * 2 / 3)
    else
        width = vim.api.nvim_get_option_value('columns', { })
    end
    local height = vim.api.nvim_get_option_value('lines', { })
    local win_height = math.ceil(height * 0.3)
    local win_width = math.ceil(width * 0.8)
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)
    _G.jir_calc_cmd_history_indx = 0
    -- Pre-fill the main buffer with empty lines to position the first result at the bottom
    main_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(main_buf, "JirCalcMain")
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
    main_win = win
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = main_buf })

    if jir_calc.settings.enable_help_window then
        -- Create a command input area at the bottom
        help_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(main_buf, "JirCalcHelp")
        local help_opts = {
            style = 'minimal',
            relative = 'editor',
            width = math.ceil(win_width / 2),
            height = win_height + 3,
            row = row,
            col = col + win_width + 2,
            border = 'rounded',
            title = ' help ',
            title_pos = 'center',
        }
        help_win = vim.api.nvim_open_win(help_buf, true, help_opts)
        vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = help_buf })
        print_help(help_buf, win_height + 3)
    end

    -- Create a command input area at the bottom
    cmd_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(main_buf, "JirCalcCMD")
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

    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = cmd_buf })
    vim.api.nvim_set_option_value('buftype', 'prompt', { buf = cmd_buf })

    vim.fn.prompt_setprompt(cmd_buf, '> ')

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
function M.close_windows()
    vim.api.nvim_win_close(cmd_win, true)
    vim.api.nvim_win_close(main_win, true)
    vim.api.nvim_win_close(help_win, true)
end

return M

