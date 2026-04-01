-- require("mini.notify").setup({})
require("mini.comment").setup({})
require("mini.starter").setup({})
require("mini.surround").setup({})
require("mini.pairs").setup({})

vim.keymap.set('n', '<leader>/', function()
    require('mini.starter').open()
end, { desc = "Go to Starter Page" })
