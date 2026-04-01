local map = vim.keymap.set

local function log(msg)
  print("[ArgManager] " .. msg)
end
-- local function log(msg)
--   vim.notify("[ArgManager] " .. msg, vim.log.levels.INFO)
-- end

local function show_args()
  local args = vim.fn.argv()
  local current_file = vim.fn.expand("%:p") -- full path of current buffer

  if #args == 0 then
    print("[Vargs] Arglist is empty")
    return
  end

  local lines = {}

  for i, file in ipairs(args) do
    local full = vim.fn.fnamemodify(file, ":p")
    local marker = (full == current_file) and "➜ " or "  "
    table.insert(lines, string.format("%s%d: %s", marker, i, file))
  end

  print(table.concat(lines, "\n"))
end

-- Arg management
map('n', '<M-a>', function()
    if vim.bo.filetype == "NvimTree_1" then
        print("[ArgManager] Skipped adding (NvimTree)")
        return
    end

    local filename = vim.fn.expand("%:t")

    vim.cmd("arga %")
    vim.cmd("silent! argdedup")

    print("[ArgManager] Added " .. filename .. " to arglist")
end)

map('n', '<M-d>', function()
    vim.cmd("silent! argdelete %")
    log("Deleted current file from arglist")
end)

map('n', '<M-c>', function()
    vim.cmd("silent! argdelete *")
    log("Cleared arglist")
end)

map('n', '<M-r>', function()
    show_args()
    -- log("Displayed arglist")
end)

map('n', '<M-h>', function()
    vim.cmd('silent! 1argument')
    log("Switched to argument 1")
end)

map('n', '<M-j>', function()
    vim.cmd('silent! 2argument')
    log("Switched to argument 2")
end)

map('n', '<M-k>', function()
    vim.cmd('silent! 3argument')
    log("Switched to argument 3")
end)

map('n', '<M-l>', function()
    vim.cmd('silent! 4argument')
    log("Switched to argument 4")
end)
