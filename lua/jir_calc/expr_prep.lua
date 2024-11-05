local M = {}
local jir_calc = require('jir_calc_setup')
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
    return binary == '' and '0' or binary
end

local function add_underscores_every_4_chars(input_str)
    local reversed_str = input_str:reverse()
    local with_underscores = reversed_str:gsub("(%d%d%d%d)", "%1_")
    local result_str = with_underscores:reverse()
    if result_str:sub(1, 1) == "_" then
        result_str = result_str:sub(2)
    end
    return result_str
end

function M.convert_result(result_str, result_base)
    if result_base == '0b' then
        result_str = dec_to_bin(tonumber(result_str))
        if jir_calc.settings.underscore then
            result_str = add_underscores_every_4_chars(result_str)
            result_base = '0b_'
        end
    elseif result_base == '0x' then
        result_str = string.format('%X', tonumber(result_str))
    elseif result_base == '' then
        result_str = tonumber(result_str)
    end

    return result_base .. result_str
end

local function split_expression(expression)
    local result = {}
    -- Use gmatch to iterate over the parts of the expression
    for part in expression:gmatch("[^%<*^/+\\-]+") do
        table.insert(result, part)
    end
    -- Use gsub to insert the delimiters into the result table
    local pattern = '([%<*^/+\\-])'
    local index = 2
    expression:gsub(pattern, function(delimiter)
        table.insert(result, index, delimiter)
        index = index + 2
    end)
    return result
end

local function pre_calc_string(calc_string)
    local words_array = split_expression(calc_string)
    for i, word in ipairs(words_array) do
        if word == '<' then
            words_array[i-1] = words_array[i-1] * 2^words_array[i+1]
            words_array[i] = ''
            words_array[i+1] = ''
        end
    end
    return table.concat(words_array, ' ')
end

function M.expr_prep(input_string)
    local input_string_eq_chk = pad_with_eq(input_string)
    local input_string_pre_eq, after_eq = string.match(input_string_eq_chk, '([^=]+)=?(.*)')
    local output_string = trim(input_string_pre_eq)
    local clean_string = remove_underscores(output_string)
    local post_pre_calculation = pre_calc_string(clean_string)
    local result_color, result_prefix = identify_base(after_eq)
    local string_to_calc = post_pre_calculation
    return output_string, string_to_calc, result_color, result_prefix
end

return M

