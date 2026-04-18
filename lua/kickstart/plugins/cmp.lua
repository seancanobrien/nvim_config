return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'onsails/lspkind.nvim', -- pretty icons
      'micangl/cmp-vimtex', -- LaTeX completion source
    },
    opts = function()
      local cmp = require 'cmp'
      local lspkind = require 'lspkind'
      local defaults = require 'cmp.config.default'()
      local auto_select = true

      vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })

      return {
        completion = {
          completeopt = 'menu,menuone,noinsert' .. (auto_select and '' or ',noselect'),
        },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm { select = auto_select },
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<S-CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace },
          ['<C-CR>'] = function(fallback)
            cmp.abort()
            fallback()
          end,
          -- ['<Tab>'] = function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   elseif vim.snippet and vim.snippet.active { direction = 1 } then
          --     vim.snippet.jump(1)
          --   else
          --     fallback()
          --   end
          -- end,
          -- ['<S-Tab>'] = function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif vim.snippet and vim.snippet.active { direction = -1 } then
          --     vim.snippet.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end,
        },
        sources = cmp.config.sources({
          { name = 'lazydev' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'vimtex' }, -- 👈 added LaTeX completion
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol_text', -- show symbol + text
            maxwidth = 50,
            ellipsis_char = '…',
            show_labelDetails = true,
            before = function(entry, vim_item)
              return vim_item
            end,
          },
        },
        experimental = {
          ghost_text = vim.g.ai_cmp and { hl_group = 'CmpGhostText' } or false,
        },
        sorting = defaults.sorting,
      }
    end,
  },
}
