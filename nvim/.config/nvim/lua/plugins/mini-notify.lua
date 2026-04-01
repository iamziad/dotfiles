local mini_notify = require('mini.notify')

mini_notify.setup({
    lsp_progress = {
        enable = false,
        level = 'INFO',
        duration_last = 1000,
    },
})

