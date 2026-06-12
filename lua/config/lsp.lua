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
        ltex_extra.setup {
          load_langs = { 'en-GB' },
          init_check = true,
          path = '.dictionaries',
        }
      end
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
vim.lsp.config('ltex', {
  cmd = { 'ltex-ls' },
  filetypes = { 'tex', 'latex', 'markdown' },
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
