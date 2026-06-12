-- [[ LSP configuration ]]
-- Uses Neovim's native vim.lsp.config()/vim.lsp.enable() (no nvim-lspconfig).
-- Server binaries are still installed standalone via mason.

require('mason').setup()
require('fidget').setup {}

-- Disable inline virtual-text diagnostics (kept as floats / signs)
vim.diagnostic.config {
  virtual_text = false,
}

-- Native insert-mode completion (replaces nvim-cmp). Buffer words still come
-- from 'complete'; LSP items come from vim.lsp.completion (enabled per-client below).
vim.o.autocomplete = true
vim.o.completeopt = 'menu,menuone,popup,noinsert'

-- ltex attaches to many buffers but is a single client; its dictionary setup
-- must run once per client, not once per buffer (ltex_extra's deferred reload
-- targets the *current* buffer and errors when focus has moved on).
local ltex_setup_done = {}

-- One LspAttach handles buffer keymaps, completion and capability-gated features
-- for every server, replacing the per-server on_attach hooks.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    -- Custom maps only. rename (grn), code action (gra), references (grr),
    -- implementation (gri) and symbols (gO) are native 0.11+ defaults.
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    -- Code actions (e.g. ltex "Add word to dictionary"). Also `gra` natively.
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    vim.keymap.set('x', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'LSP: [C]ode [A]ction' })

    -- Enable native LSP completion for this client/buffer
    if client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    -- Document highlighting on cursor hold
    if client:supports_method 'textDocument/documentHighlight' then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight-' .. bufnr, { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = bufnr,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Inlay hints (start disabled, toggle with <leader>th)
    if client:supports_method 'textDocument/inlayHint' then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
      end, '[T]oggle Inlay [H]ints')
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end

    -- ltex-specific: load custom dictionaries / disabled rules (once per client).
    if client.name == 'ltex' and not ltex_setup_done[client.id] then
      ltex_setup_done[client.id] = true
      local lang = 'en-GB'

      -- ltex_extra only for its add-to-dictionary / hide-false-positive / disable-
      -- rule code-action commands. init_check is OFF: its reload defers a
      -- current-buffer lookup that errors when ltex (slow JVM) attaches to a
      -- background buffer, so we load the persisted lists ourselves below.
      pcall(function()
        require('ltex_extra').setup { load_langs = { lang }, init_check = false, path = '.dictionaries' }
      end)

      -- Read a `.txt` word/rule list, one entry per line, or {} if missing.
      local function read_list(path)
        return vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {}
      end

      -- Project lists live at <cwd>/.dictionaries/ltex.<type>.<lang>.txt
      -- (the same files ltex_extra reads/writes); the dictionary also gets a
      -- global word list shared across all projects merged on top.
      local proj = vim.fs.normalize(vim.uv.cwd() .. '/.dictionaries')
      local dict = read_list(proj .. '/ltex.dictionary.' .. lang .. '.txt')
      for _, w in ipairs(read_list(vim.fn.expand '~/.config/nvim/ltex/dictionary.' .. lang .. '.txt')) do
        if w ~= '' and not vim.tbl_contains(dict, w) then
          table.insert(dict, w)
        end
      end

      local settings = client.config.settings
      settings.ltex = settings.ltex or {}
      settings.ltex.dictionary = { [lang] = dict }
      settings.ltex.disabledRules = { [lang] = read_list(proj .. '/ltex.disabledRules.' .. lang .. '.txt') }
      settings.ltex.hiddenFalsePositives = { [lang] = read_list(proj .. '/ltex.hiddenFalsePositives.' .. lang .. '.txt') }
      client:notify('workspace/didChangeConfiguration', settings)
    end
  end,
})

-- Lua Language Server
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Add other library paths if needed
        },
      },
      completion = {
        callSnippet = 'Replace',
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
vim.lsp.enable 'lua_ls'

-- basedpyright (python)
vim.lsp.config('basedpyright', {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
})
vim.lsp.enable 'basedpyright'

-- LTeX (LaTeX/Markdown grammar checking). ltex_extra is wired up in LspAttach.
-- Uses ltex-ls-plus (maintained fork); the original valentjn/ltex-ls leaks
-- LanguageTool warnings onto stdout, corrupting the LSP stream so it never attaches.
vim.lsp.config('ltex', {
  cmd = { 'ltex-ls-plus' },
  filetypes = { 'tex', 'latex', 'markdown' },
  -- Neovim's filetype for *.tex is `tex`, but ltex only checks documents whose
  -- languageId is in its enabled set (`latex`, `markdown`, ...) and `tex` is not.
  -- Translate so LaTeX files actually get grammar-checked.
  get_language_id = function(_, filetype)
    if filetype == 'tex' then
      return 'latex'
    end
    return filetype
  end,
  settings = {
    ltex = {
      language = 'en-GB',
    },
  },
})
vim.lsp.enable 'ltex'

-- TexLab (LaTeX language server + formatting)
vim.lsp.config('texlab', {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'latex' },
  root_markers = { '.git', 'texlabroot', 'main.tex' },
  settings = {
    texlab = {
      build = {
        onSave = false,
      },

      -- THIS is the important part
      latexFormatter = 'latexindent',
      latexindent = {
        modifyLineBreaks = true,
        -- This seems like the only way to load more specific settings.
        -- Forces settings to be global.
        ['local'] = '/home/sean/.config/nvim/latexindent/indentSettings.yaml',
      },
    },
  },
})
vim.lsp.enable 'texlab'

-- vim: ts=2 sts=2 sw=2 et
