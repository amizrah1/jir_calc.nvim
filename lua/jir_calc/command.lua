local M = {}

-- Function to handle user commands
function M.handle_command()
  local cmd_buf = vim.api.nvim_get_current_buf()
  local expr = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]
  
  local result, err = load("return " .. expr)
  if err then
    vim.api.nvim_err_writeln("Error: " .. err)
  else
    local success, value = pcall(result)
    if success then
      vim.api.nvim_out_write("Result: " .. value .. "\n")
    else
      vim.api.nvim_err_writeln("Error: " .. value)
    end
  end

  vim.api.nvim_win_close(0, true)
end

return M
