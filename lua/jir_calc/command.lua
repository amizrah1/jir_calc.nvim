local M = {}

-- Function to handle user commands
function M.handle_command()
  local cmd_buf = vim.api.nvim_get_current_buf()
  local cmd = vim.api.nvim_buf_get_lines(cmd_buf, 0, -1, false)[1]
  vim.api.nvim_command(cmd)
  vim.api.nvim_win_close(0, true)
end

return M
