local M = {}
local common = require('jir_calc.common')

local function identify_base(after_eq)
    local result_color = common.HL_Error
    local result_prefix = ''
    if string.sub(after_eq, 1, 1) == 'b' then
        result_color = common.HL_Bin
        result_prefix = '0b'
    elseif string.sub(after_eq, 1, 1) == 'h' then
        result_color = common.HL_Hex
        result_prefix = '0x'
    elseif string.sub(after_eq, 1, 1) == 'd' then
        result_color = common.HL_Dec
    else
        result_color = common.HL_Dec
    end
    return result_color, result_prefix
end

local function pad_with_eq(input_string)
    if not string.find(input_string, '=') then
        input_string = input_string .. ' = '
    end
    return input_string
end

local function trim(s)
    return (s:gsub('^%s*(.-)%s*$', '%1'))
end

local function remove_underscores(s)
    return (s:gsub('_', ''))
end

local function dec_to_bin(num)
    local binary = ''
    while num > 0 do
        binary = (num % 2) .. binary
        num = math.floor(num / 2)
    end
    print(binary)
    return binary == '' and '0' or binary
end

function M.convert_result(result_str, result_base)
    if result_base == '0b' then
        result_str = dec_to_bin(tonumber(result_str))
    elseif result_base == '0x' then
        result_str = string.format('%X', tonumber(result_str))
    elseif result_base == '' then
        result_str = tonumber(result_str)
    end

    return result_base .. result_str
end

local function split_expression(expression)
    local result = {}
    local pattern = '([+\\-*/^()])'
    -- Use gmatch to iterate over the parts of the expression
    for part in expression:gmatch('[^+\\-*/^()]+') do
        table.insert(result, part)
    end
    -- Use gsub to insert the delimiters into the result table
    local index = 2
    expression:gsub(pattern, function(delimiter)
        table.insert(result, index, delimiter)
        index = index + 2
    end)
    return result
end

function M.expr_prep(input_string)
    local result_prefix = ''
    local result_color
    local input_string_pad
    local output_string
    local calc_string
    local after_eq

    local words_array = split_expression('A+B/C*D-E*F')
    print('Array of words:')
    for i, word in ipairs(words_array) do
        print(i, word)
    end
    input_string = pad_with_eq(input_string)
    input_string_pad, after_eq = string.match(input_string, '([^=]+)=?(.*)')
    result_color, result_prefix = identify_base(after_eq)
    output_string = trim(input_string_pad)
    calc_string = remove_underscores(output_string)
    return output_string, calc_string, result_color, result_prefix
end

return M

