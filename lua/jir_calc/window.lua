local M = {}

-- Function to open a floating window
function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.3)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "single"
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Create a command input area at the bottom
  local cmd_buf = vim.api.nvim_create_buf(false, true)
  local cmd_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = 1,
    row = row + win_height,
    col = col,
    border = "single"
  }
  local cmd_win = vim.api.nvim_open_win(cmd_buf, true, cmd_opts)
  vim.api.nvim_buf_set_option(cmd_buf, "bufhidden", "wipe")

  -- Capture user input
  vim.api.nvim_buf_set_keymap(cmd_buf, "i", "<CR>", "<cmd>lua require'jir_calc.command'.handle_command()<CR>", { noremap = true, silent = true })

  return win, cmd_win
end

return M
