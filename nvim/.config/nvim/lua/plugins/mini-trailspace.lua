require('mini.trailspace').setup()

local set_trail_color = function()
    vim.api.nvim_set_hl(0, "MiniTrailspace", { bg = "#555555", fg = "none" })
end

set_trail_color()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_trail_color,
})

vim.keymap.set('n', '<leader>ts', function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
end, { desc = 'Trim spaces and lines' })
