-- -- Setup mini.pick
-- require("mini.pick").setup()
--
-- -- Setup mini.extra
-- require("mini.extra").setup()
--
-- local pick = require("mini.pick")
-- local extra = require("mini.extra")
--
-- -- Files
-- vim.keymap.set("n", "<leader>ff", pick.builtin.files, { desc = "Find files" })
--
-- -- Live grep
-- vim.keymap.set("n", "<leader>fg", extra.pickers.live_grep, { desc = "Live grep" })
--
-- -- Buffers
-- vim.keymap.set("n", "<leader>fb", pick.builtin.buffers, { desc = "Buffers" })
--
-- -- Help tags
-- vim.keymap.set("n", "<leader>fh", pick.builtin.help, { desc = "Help tags" })
--
-- -- Diagnostics
-- vim.keymap.set("n", "<leader>fd", extra.pickers.diagnostic, { desc = "Diagnostics" })



local pick = require('mini.pick')

-- Setup mini.pick with default configuration
pick.setup({
    -- Delay (in ms) between forcing update for the current query
    delay = {
        async = 10,
        busy = 50,
    },

    -- Keys for performing actions
    mappings = {
        caret_left  = '<Left>',
        caret_right = '<Right>',

        choose            = '<CR>',
        choose_in_split   = '<C-s>',
        choose_in_tabpage = '<C-t>',
        choose_in_vsplit  = '<C-v>',
        choose_marked     = '<M-CR>',

        delete_char       = '<BS>',
        delete_char_right = '<Del>',
        delete_left       = '<C-u>',
        delete_word       = '<C-w>',

        mark     = '<C-x>',
        mark_all = '<C-a>',

        move_down  = '<C-n>',
        move_start = '<C-g>',
        move_up    = '<C-p>',

        paste = '<C-r>',

        refine        = '<C-Space>',
        refine_marked = '<M-Space>',

        scroll_down  = '<C-f>',
        scroll_left  = '<C-h>',
        scroll_right = '<C-l>',
        scroll_up    = '<C-b>',

        stop = '<Esc>',

        toggle_info    = '<S-Tab>',
        toggle_preview = '<Tab>',
    },

    -- General options
    options = {
        content_from_bottom = true,
        use_cache = false,
    },

    -- Source definition
    source = {
        items = nil,
        name = nil,
        cwd = nil,

        match = nil,
        show = nil,
        preview = nil,

        choose = nil,
        choose_marked = nil,
    },

    -- Window configuration
    window = {
        -- config = function()
            --     local height = math.floor(0.618 * vim.o.lines)
            --     local width = math.floor(0.618 * vim.o.columns)
            --     return {
                --         anchor = 'SW',
                --         height = height,
                --         width = width,
                --         row = vim.o.lines - 2,
                --         col = math.floor(0.5 * (vim.o.columns - width)),
                --         border = 'single',
                --     }
                -- end,
                config = nil
            },
        })


        -- Helper function to pick files with preview
        local function pick_files()
            pick.builtin.files({}, {
                source = {
                    preview = function(buf_id, item)
                        -- Preview file content
                        local path = item
                        if vim.fn.filereadable(path) == 1 then
                            local lines = vim.fn.readfile(path, '', 100)
                            vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
                            vim.bo[buf_id].filetype = vim.filetype.match({ filename = path })
                        end
                    end
                }
            })
        end

        -- Helper function for ctags
        local function pick_ctags()
            -- Check if tags file exists
            if vim.fn.filereadable('tags') == 0 then
                vim.notify('No tags file found. Generate tags first with :!ctags -R', vim.log.levels.WARN)
                return
            end

            -- Read and parse tags file
            local tags_file = vim.fn.readfile('tags')
            local items = {}

            for _, line in ipairs(tags_file) do
                -- Skip comments
                if not line:match('^!') then
                    local parts = vim.split(line, '\t')
                    if #parts >= 3 then
                        local tag = parts[1]
                        local file = parts[2]
                        local pattern = parts[3]

                        table.insert(items, {
                            text = string.format('%-30s %s', tag, file),
                            tag = tag,
                            file = file,
                            pattern = pattern,
                        })
                    end
                end
            end

            pick.start({
                source = {
                    items = items,
                    name = 'CTags',
                    choose = function(item)
                        if item then
                            -- Open the file
                            vim.cmd('edit ' .. item.file)

                            -- Search for the pattern
                            local search_pattern = item.pattern:gsub('^/', ''):gsub('/$', '')
                            vim.fn.search(search_pattern)
                        end
                    end,
                    preview = function(buf_id, item)
                        if item and vim.fn.filereadable(item.file) == 1 then
                            local lines = vim.fn.readfile(item.file)
                            vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
                            vim.bo[buf_id].filetype = vim.filetype.match({ filename = item.file })
                        end
                    end,
                }
            })
        end

        -- Register custom pickers
        _G.MiniPickCustom = {
            files = pick_files,
            ctags = pick_ctags,
        }

        -- Keymaps for mini.pick
        local map = vim.keymap.set


        -- General pickers
        map('n', '<leader>ff', function() pick_files() end, { desc = 'Pick: Find files' })
        map('n', '<leader>fg', function() pick.builtin.grep_live() end, { desc = 'Pick: Live grep' })
        map('n', '<leader>fb', function() pick.builtin.buffers() end, { desc = 'Pick: Buffers' })
        map('n', '<leader>fh', function() pick.builtin.help() end, { desc = 'Pick: Help tags' })
        map('n', '<leader>fr', function() pick.builtin.resume() end, { desc = 'Pick: Resume last picker' })
        map('n', '<leader>f/', function() pick.builtin.grep() end, { desc = 'Pick: Grep' })

        -- CTags keymaps
        map('n', '<leader>ft', function() pick_ctags() end, { desc = 'Pick: CTags' })
        map('n', '<leader>tj', function() pick_ctags() end, { desc = 'Pick: Jump to tag' })

        -- Additional useful keymaps
        map('n', '<leader>fc', function()
            pick.builtin.files({ tool = 'git' })
        end, { desc = 'Pick: Git files' })

        -- Grep word under cursor
        map('n', '<leader>fw', function()
            local word = vim.fn.expand('<cword>')
            pick.builtin.grep({ pattern = word })
        end, { desc = 'Pick: Grep word under cursor' })

        -- Grep visual selection
        map('v', '<leader>fw', function()
            -- Get visual selection
            vim.cmd('normal! "vy')
            local selection = vim.fn.getreg('v')
            pick.builtin.grep({ pattern = selection })
        end, { desc = 'Pick: Grep selection' })


        require('mini.extra').setup()

        -- Additional keymaps using mini.extra pickers
        local MiniExtra = require('mini.extra')

        map('n', '<leader>fo', function() MiniExtra.pickers.oldfiles() end, { desc = 'Pick: Old files' })
        map('n', '<leader>fx', function() MiniExtra.pickers.diagnostic() end, { desc = 'Pick: Diagnostics' })
        map('n', '<leader>fm', function() MiniExtra.pickers.marks() end, { desc = 'Pick: Marks' })
        map('n', '<leader>fk', function() MiniExtra.pickers.keymaps() end, { desc = 'Pick: Keymaps' })
        map('n', '<leader>fH', function() MiniExtra.pickers.hl_groups() end, { desc = 'Pick: Highlight groups' })
        map('n', '<leader>fl', function() MiniExtra.pickers.buf_lines() end, { desc = 'Pick: Buffer lines' })

