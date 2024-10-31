local M = {}

local log_file = vim.fn.stdpath("data") .. "/jir_calc.log"

function M.log(message)
	local file = io.open(log_file, "a")
	if file then
		file:write(message .. "\n")
		file:close()
	end
end

return M
