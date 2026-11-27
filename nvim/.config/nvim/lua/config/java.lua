-- Everything Java-specific lives in this file.
--
-- The plugin `nvim-java` does the heavy lifting:
--   * it downloads and starts jdtls (Eclipse JDT Language Server) itself
--   * it adds the Java extras: opening JDK / library classes (jdt:// files) when
--     you press `gd` on e.g. `String`, organize imports, extract variable /
--     constant / method, running and debugging tests and `main`, Spring Boot
--   * it installs its own JDK if you don't point it at one
--
-- Your projects can still target an older Java than the one running jdtls.

-- Reuse the JDK already on your PATH instead of downloading another one (~200 MB).
local java_bin = vim.fn.exepath('java')
local jdk_home = java_bin ~= '' and vim.fs.dirname(vim.fs.dirname(vim.fn.resolve(java_bin))) or nil

require('java').setup({
  jdk = jdk_home and { auto_install = false, path = jdk_home } or nil,
})

-- Fine-tune jdtls. nvim-java already set the defaults (cmd, root markers,
-- extended client capabilities, java-test / java-debug plugins, ...);
-- vim.lsp.config() merges these settings on top of them.
vim.lsp.config('jdtls', {
  settings = {
    java = {
      -- Download library sources so `gd` into a dependency shows real code, not a decompiled stub.
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      -- When no source is available, decompile the class.
      contentProvider = { preferred = 'fernflower' },
      signatureHelp = { enabled = true },
      -- Use real imports (java.util.List) instead of java.util.* when organizing imports.
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },

      -- If your project uses a different JDK than the one running jdtls, list them here.
      -- (the `name` must be like JavaSE-17 / JavaSE-21, the path is your JDK folder)
      -- configuration = {
      --   runtimes = {
      --     { name = 'JavaSE-21', path = '/usr/lib/jvm/java-21-openjdk' },
      --   },
      -- },
    },
  },
})

-- Start jdtls. nvim-java registered its configuration above.
vim.lsp.enable('jdtls')

-- Java uses 4 spaces (the rest of the config uses 2).
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

-- Java-only shortcuts: they appear only when the jdtls server attaches.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-java-attach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= 'jdtls' then
      return
    end

    local function map(mode, keys, fn, desc)
      vim.keymap.set(mode, keys, fn, { buffer = ev.buf, desc = 'Java: ' .. desc })
    end

    -- nvim-java fills `require('java').refactor` when jdtls attaches, so look the
    -- function up when you press the key instead of when the mapping is created.
    local function refactor(name)
      return function()
        require('java').refactor[name]()
      end
    end

    map('n', '<leader>jo', function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { 'source.organizeImports' } },
      })
    end, 'Organize imports')
    map({ 'n', 'x' }, '<leader>jv', refactor('extract_variable'), 'Extract variable')
    map({ 'n', 'x' }, '<leader>jc', refactor('extract_constant'), 'Extract constant')
    map({ 'n', 'x' }, '<leader>jm', refactor('extract_method'), 'Extract method')
    map('n', '<leader>ju', '<cmd>JavaBuildBuildWorkspace<cr>', 'Rebuild workspace (after changing pom.xml / build.gradle)')
  end,
})
