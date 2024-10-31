local M = {}

local function is_empty_or_spaces(str)
	return str:match("^%s*$") ~= nil
end

local function expr_prep(calc_expr)
    local value = calc_expr
    return value
end

-- Function to handle user commands
function M.handle_command(main_win)
	local cmd_buf = vim.api.nvim_get_current_buf()
	local expr = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]
	local output_string

	-- Strip the leading "> " from the expression
	expr = expr:sub(3)

	if is_empty_or_spaces(expr) then
        vim.api.nvim_err_writeln("Error: Empty expression")
    else
        local temp_expr = expr_prep(expr)
        local result_expr, err = load("return " .. temp_expr)
        if err then
            vim.api.nvim_err_writeln("Error: " .. err)
        else
            local success, value = pcall(result_expr)
            if success then
                local main_buf = vim.api.nvim_win_get_buf(main_win)
                local line_count = vim.api.nvim_buf_line_count(main_buf)
                output_string = expr .. " = " .. value
                vim.api.nvim_buf_set_lines(main_buf, line_count, line_count, false, { output_string })
                vim.api.nvim_win_set_cursor(main_win, { line_count + 1, 0 })
            else
                vim.api.nvim_err_writeln("Error: " .. value)
            end
        end
    end

	-- Clear the command buffer and keep it in insert mode
	vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { "> " })
	vim.api.nvim_command("startinsert")
	vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Position cursor after "> "
end

return M
