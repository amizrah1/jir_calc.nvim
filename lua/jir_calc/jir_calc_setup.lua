local M = {}

_G.jir_result_history = _G.jir_result_history or {}
_G.jir_cmd_history = _G.jir_cmd_history or {}
_G.jir_Memory = _G.jir_Memory or {}
_G.jir_cmd_history_indx = 0
_G.jir_last_result = 0

M.settings = {
    underscore = false,
    print_processed = false,
    last_answer_access_string = 'ans',
}

function M.setup(opts)
    M.settings = vim.tbl_deep_extend("force", M.settings, opts or {})
end

return M

