local M = {}

-- Define your shared variables here
M.result_color = "Error"  -- Default highlight group for the result
    local HL_Header = vim.fn.synIDattr(vim.fn.hlID("Number"), "name")
    local HL_Dec    = vim.fn.synIDattr(vim.fn.hlID("Statement"), "name")
    local HL_Bin    = vim.fn.synIDattr(vim.fn.hlID("String"), "name")
    local HL_Hex    = vim.fn.synIDattr(vim.fn.hlID("PreProc"), "name")
    local HL_Error  = vim.fn.synIDattr(vim.fn.hlID("Operator"), "name")

return M

