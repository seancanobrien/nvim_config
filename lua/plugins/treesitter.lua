-- Highlight, edit, and navigate code (nvim-treesitter `main` branch).
-- The `main` rewrite is a different plugin from the legacy `master` API: no
-- `nvim-treesitter.configs`, no `auto_install`, no incremental-selection module.
require('nvim-treesitter').setup {}

-- Install a fixed set of parsers (no auto_install on `main`). :TSUpdate (run from
-- the PackChanged hook) keeps them current; markdown needs markdown_inline too.
require('nvim-treesitter').install {
  'bash',
  'c',
  'commonlisp',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'vim',
  'vimdoc',
}

-- Start treesitter highlighting + indentation per buffer. VimTeX owns LaTeX
-- highlighting, so we skip tex/latex.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == 'tex' or ft == 'latex' then
      return
    end
    -- vim.treesitter.start errors if there is no parser for this filetype.
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
