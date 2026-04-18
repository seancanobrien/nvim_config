return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true },
      -- 'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      -- Global LSP configuration using vim.lsp.config()
      local global_on_attach = function(client, bufnr)
        -- Create a function for easy keymap creation
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        -- LSP keymaps
        map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
        map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
        map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        map('<leader>~b', vim.lsp.buf.document_symbol, '[~]ymbols in [B]uffer')
        map('<leader>~w', vim.lsp.buf.workspace_symbol, '[~]ymbols in [W]orkspace')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Document highlighting
        if client and client.server_capabilities.documentHighlightProvider then
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

        -- Inlay hints
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
          end, '[T]oggle Inlay [H]ints')
          -- Start with inlays disabled
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end

        -- Disable virtual text diagnostics
        vim.diagnostic.config {
          virtual_text = false,
        }
      end

      -- Lua Language Server
      vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml' },
        on_attach = global_on_attach,
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

      -- LTeX (LaTeX/Markdown grammar checking)
      vim.lsp.config('ltex', {
        cmd = { 'ltex-ls' },
        filetypes = { 'tex', 'latex', 'markdown' },
        settings = {
          ltex = {
            language = 'en-GB',
          },
        },

        on_attach = function(client, bufnr)
          -- Delay attach until the buffer is fully initialized
          -- vim.schedule(function()
          --   if not vim.api.nvim_buf_is_valid(bufnr) then
          --     return
          --   end

          -- Call the global on_attach first
          if global_on_attach then
            pcall(global_on_attach, client, bufnr)
          end

          -- Then add ltex-specific setup
          local ok, ltex_extra = pcall(require, 'ltex_extra')
          if ok then
            ltex_extra.setup {
              load_langs = { 'en-GB' },
              init_check = true,
              path = '.dictionaries',
            }
          end
          -- end
          -- )
        end,
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

        on_attach = function(client, bufnr)
          -- Call your global on_attach
          pcall(global_on_attach, client, bufnr)
          if global_on_attach then
            global_on_attach(client, bufnr)
          end
        end,
      })
      vim.lsp.enable 'texlab'

      -- Setup Mason for automatic installation
      require('mason').setup()
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
