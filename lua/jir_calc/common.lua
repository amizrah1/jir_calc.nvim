local M = {}

-- Define your shared variables here
M.HL_Header = vim.fn.synIDattr(vim.fn.hlID("Number"), "name")
M.HL_Dec    = vim.fn.synIDattr(vim.fn.hlID("Statement"), "name")
M.HL_Bin    = vim.fn.synIDattr(vim.fn.hlID("String"), "name")
M.HL_Hex    = vim.fn.synIDattr(vim.fn.hlID("PreProc"), "name")
M.HL_Error  = vim.fn.synIDattr(vim.fn.hlID("Operator"), "name")

return M
