local M = {}
local jir_calc = require('jir_calc_setup')
local expr_prep_module = require('jir_calc.expr_prep')
local common= require('jir_calc.common')

local function is_empty_or_spaces(str)
    return str:match('^%s*$') ~= nil
end

local function err_check_and_convert(err)
    if type(err) == "boolean" then
        return tostring(err)
    elseif err == nil then
        return "nil"
    else
        return "Value is neither boolean nor nil"
    end
end

local function handle_history(expr)
    local temp_expr = expr:sub(3) -- Strip the leading '> ' from the expression
    temp_expr = (temp_expr:gsub(' ', ''))
    if not is_empty_or_spaces(temp_expr) then
        local cmd_history = string.gsub(expr, "%s+$", "")
        table.insert(_G.jir_cmd_history, cmd_history)
        _G.jir_cmd_history_indx = 0
    end
end

local function calculate(expr, cmd_buf, main_win)
    local output_string = ''
    local processed_expr, result_color, result_base
    local main_buf
    local line_count
    local output_string_w_results = ''
    result_color = common.HL_Normal
    expr = expr:sub(3) -- Strip the leading '> ' from the expression

    if is_empty_or_spaces(expr) then
        output_string_w_results = ' '
    else
        output_string, processed_expr, result_color, result_base = expr_prep_module.expr_prep(expr)
        local result_expr, err = load('return ' .. processed_expr)
        if err then
            output_string_w_results = 'Loading Error: ' .. result_expr .. " \n" .. err_check_and_convert(err)
        else
            local success, value = pcall(result_expr)
            if success then
                local result_string = expr_prep_module.convert_result(value, result_base)
                if jir_calc.settings.print_processed then
                    output_string_w_results = processed_expr .. ' = ' .. result_string
                else
                    output_string_w_results = output_string .. ' = ' .. result_string
                end
                _G.jir_last_result = result_string
            else
                output_string_w_results = 'Input: ' .. processed_expr .. ", Error: ".. err_check_and_convert(err)
                output_string = output_string_w_results
            end
        end
    end
    main_buf = vim.api.nvim_win_get_buf(main_win)
    line_count = vim.api.nvim_buf_line_count(main_buf)
    vim.api.nvim_buf_set_lines(main_buf, line_count, line_count, false, { output_string_w_results })
    vim.api.nvim_buf_add_highlight(main_buf, -1, result_color, line_count, #output_string + 3, #output_string_w_results)
    vim.api.nvim_win_set_cursor(main_win, { line_count + 1, 0 })

    table.insert(_G.jir_result_history, output_string_w_results)

    -- Clear the command buffer and keep it in insert mode
    vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { '> ' })
    vim.api.nvim_command('startinsert')
    vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Position cursor after '> '
end

function M.handle_command(main_win)
    local cmd_buf = vim.api.nvim_get_current_buf()
    local expr = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]
    handle_history(expr)
    calculate(expr, cmd_buf, main_win)
end



return M

