require('mini.indentscope').setup({
    draw = {
        delay = 0,
        animation = function() return 0 end,
    },
        -- symbol = "│",
        symbol = "╎",
        -- symbol = "┆",
        -- symbol = "┊",
})

-- local set_color = function()
--     vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#444444", force = true })
-- end
--
-- set_color()
--
-- vim.api.nvim_create_autocmd("ColorScheme", {
--     callback = set_color,
-- })
