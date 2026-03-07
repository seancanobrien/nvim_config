return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'commonlisp' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- We want VimTex to do highlighting for latex
        disable = { 'latex' },
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          scope_incremental = '<CR>',
          node_incremental = '<TAB>',
          node_decremental = '<S-TAB>',
        },
      },

      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- custom maxima parser (WIP!)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.maxima = {
        install_info = {
          url = 'https://github.com/mrseanman/tree-sitter-maxima', -- local path or git repo
          -- url = '/home/sean/Documents/tree-sitter-maxima', -- local path or git repo
          files = { 'src/parser.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
          -- optional entries:
          branch = 'main', -- default branch in case of git repo if different from master
          generate_requires_npm = true, -- if stand-alone parser without npm dependencies
          requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
        },
        filetype = 'maxima', -- if filetype does not match the parser name
      }

      vim.treesitter.language.register('maxima', 'maxima') -- the someft filetype will use the python parser and queries.

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
