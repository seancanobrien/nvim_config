vim.filetype.add {
  extension = {
    m = 'mma',
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'mma', -- Trigger for Mathematica files
  callback = function()
    vim.bo.commentstring = '(* %s *)'
  end,
})
