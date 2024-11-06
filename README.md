# jir_calc.nvim

calculator inside neovim

## Documentation
*jir_calc.txt*    Plugin for Neovim

jir_calc.nvim
=============
This plugin provides a floating window with a command input area at the bottom.
```lua
return {
    'amizrah1/jir_calc.nvim',
    name = 'jir_calc',
    config = function()
        require('jir_calc.jir_calc_setup').setup({
            pad_with_underscore = true,
            enable_help_window = true,
            reformat_output = true,
            print_processed = false,
        })
        vim.keymap.set('n', '<leader>m',       function() require('jir_calc.window').open_window() end , { desc = 'Jir Calculator' })
    end
}
```
Usage:
------
Run `:lua require('jir_calc.window').open_window()` to open the floating window.
or map vim.keymap.set('n', '<leader>m',       function() require('jir_calc.window').open_window() end , { desc = 'Jir Calculator' })

    'add =b to get binary result',
    'add =h to get hex result (or =x)',
    'send binary by using prefix 0b - 0b0111 = 7',
    'send hex by using prefix 0x    - 0x0F = 15',
    'you can use _ as much as you want, jir is ignoring _ for example 0b_0011_0011',
    'shift 1<4 = 16',
    'use ANS or ans to get last result into calculation',
    '\\M1 store value in Memory (any string after backslash)',
    '\\MC clears memory',
    '\\MR recalls memory',
    'modulo %',
    'abs(x): Returns the absolute value of x.',
    'exp(x): Returns the value of e^x.',
    'log(x): Returns the natural logarithm of x.',
    'log(x, base): Returns the logarithm of x with the specified base.',
    'log10(x): Returns the base-10 logarithm of x.',
    'sin(x): Returns the sine of x (x is in radians). etc.',
    'asin(x): Returns the arcsine of x (in radians). etc.',
    'sqrt(x): Returns the square root of x.',
    'random(): Returns a random number between 0 and 1.',
    'random(n): Returns a random integer between 1 and n.',
    'random(m, n): Returns a random integer between m and n.',
    'pi: The value of π (pi).',

Author:
-------
Jir
