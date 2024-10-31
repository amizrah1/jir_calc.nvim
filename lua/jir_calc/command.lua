local log = require("jir_calc.log")

local M = {}

local function is_empty_or_spaces(str)
	return str:match("^%s*$") ~= nil
end

-- Function to handle user commands
function M.handle_command(main_win)
	local cmd_buf = vim.api.nvim_get_current_buf()
	local expr = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]

	-- Strip the leading "> " from the expression
	expr = expr:sub(3)

	local result, err = load("return " .. expr)
	if is_empty_or_spaces(expr) then
		vim.api.nvim_err_writeln("Error: Empty expression")
		log.log("Error: Empty expression")
	else
		if err then
			vim.api.nvim_err_writeln("Error: " .. err)
			log.log("Error: " .. err)
		else
			local success, value = pcall(result)
			if success then
				vim.api.nvim_out_write("" .. expr .. value .. "\n")
				log.log("Result: " .. value)
				-- Update the main window buffer with the result
				local main_buf = vim.api.nvim_win_get_buf(main_win)
				vim.api.nvim_buf_set_lines(main_buf, -1, -1, false, { "Result: " .. value })
			else
				vim.api.nvim_err_writeln("Error: " .. value)
				log.log("Error: " .. value)
			end
		end
	end

	-- Clear the command buffer and keep it in insert mode
	vim.api.nvim_buf_set_lines(cmd_buf, 0, -1, false, { "> " })
	vim.api.nvim_command("startinsert")
	vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Position cursor after "> "
end

return M
