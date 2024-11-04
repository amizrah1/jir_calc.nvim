local M = {}

M.settings = {
    underscore = false,
    last_answer_access_string = 'ans',
}

function M.setup(opts)
    M.settings = vim.tbl_deep_extend("force", M.settings, opts or {})
end

return M

