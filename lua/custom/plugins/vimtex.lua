return {
  -- VimTeX
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    init = function()
      -- makes the quickfix window go away after any keystrokes
      vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1
      -- disable vimtex completion (this is handled by texlab)
      vim.g.vimtex_complete_enabled = 0
      -- vim.g.vimtex_indent_enabled = 1
      vim.g.vimtex_view_method = 'zathura_simple'
      vim.g.vimtex_compiler_latexmk = {
        -- Directory for output pdf and auxilary files
        out_dir = 'build',
      }
    end,
  },
}
