local M = {}
local expr_prep_module = require('jir_calc.expr_prep')

local function is_empty_or_spaces(str)
    return str:match('^%s*$') ~= nil
end

-- Function to handle user commands
function M.handle_command(main_win)
    local cmd_buf = vim.api.nvim_get_current_buf()
    local expr = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]

    expr = expr:sub(3) -- Strip the leading '> ' from the expression
    if is_empty_or_spaces(expr) then
        vim.api.nvim_err_writeln('Error: Empty expression')
    else
        local output_string, processed_expr, result_color, result_base = expr_prep_module.expr_prep(expr)
        local result_expr, err = load('return ' .. processed_expr)
        if err then
            vim.api.nvim_err_writeln('Error: ' .. err)
        else
            local success, value = pcall(result_expr)
            if success then
                local main_buf = vim.api.nvim_win_get_buf(main_win)
                local line_count = vim.api.nvim_buf_line_count(main_buf)
                local result_string = expr_prep_module.convert_result(value, result_base)
                local output_string_w_results = output_string .. ' = ' .. result_string
                vim.api.nvim_buf_set_lines(main_buf, line_count, line_count, false, { output_string_w_results })
                vim.api.nvim_buf_add_highlight(main_buf, -1, result_color, line_count, #output_string + 3, #output_string_w_results)
                vim.api.nvim_win_set_cursor(main_win, { line_count + 1, 0 })
            else
                vim.api.nvim_err_writeln('Error: ' .. value)
            end
        end
    end

    -- Clear the command buffer and keep it in insert mode
    vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { '> ' })
    vim.api.nvim_command('startinsert')
    vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Position cursor after '> '
end

return M


