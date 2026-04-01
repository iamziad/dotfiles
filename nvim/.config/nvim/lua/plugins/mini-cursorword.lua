require('mini.cursorword').setup(opts)

local set_cursorword_style = function()
    vim.api.nvim_set_hl(0, "MiniCursorword", { underline = true, fg = "none" , sp = "none" })
    vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { underline = false, bg = "none", sp = "none" })
end

set_cursorword_style()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_cursorword_style,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function()
        vim.b.minicursorword_disable = true
    end,
})
