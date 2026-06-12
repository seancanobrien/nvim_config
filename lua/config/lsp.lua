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

    -- ltex-specific: load custom dictionaries / disabled rules
    if client.name == 'ltex' then
      local ok, ltex_extra = pcall(require, 'ltex_extra')
      if ok then
        -- Runs synchronously: replaces settings.ltex.dictionary['en-GB'] with the
        -- project's .dictionaries words and notifies the server.
        ltex_extra.setup {
          load_langs = { 'en-GB' },
          init_check = true,
          path = '.dictionaries',
        }
      end

      -- Merge a global word list (shared across all projects) into the project
      -- dictionary. The ':'-prefixed external-file syntax is a VSCode-client
      -- feature the server doesn't expand, so we read the file ourselves and
      -- pass the words inline (the mechanism ltex-extra uses for project words).
      -- ltex_extra.reload() defers its dictionary update via vim.schedule and
      -- replaces dictionary['en-GB'] wholesale, so schedule our merge to run
      -- after it (queued later on the same event loop) or it gets clobbered.
      local global_path = vim.fn.expand '~/.config/nvim/ltex/dictionary.en-GB.txt'
      local global_words = vim.fn.filereadable(global_path) == 1 and vim.fn.readfile(global_path) or {}
      vim.schedule(function()
        local settings = client.config.settings
        settings.ltex = settings.ltex or {}
        settings.ltex.dictionary = settings.ltex.dictionary or {}
        local words = settings.ltex.dictionary['en-GB'] or {}
        for _, w in ipairs(global_words) do
          if w ~= '' and not vim.tbl_contains(words, w) then
            table.insert(words, w)
          end
        end
        settings.ltex.dictionary['en-GB'] = words
        client:notify('workspace/didChangeConfiguration', settings)
      end)
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
