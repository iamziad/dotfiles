
require("notify").setup({
  stages = "static",
  timeout = 3000,
  render = "wrapped-compact",
})

vim.notify = require("notify")
