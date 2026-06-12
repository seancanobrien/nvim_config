-- Search the undo tree using telescope.
-- Calling telescope's setup again is harmless; it merges configs (each extension
-- lives in its own namespace).
require('telescope').setup {
  extensions = {
    undo = {
      -- telescope-undo.nvim config
    },
  },
}
require('telescope').load_extension 'undo'

vim.keymap.set('n', '<leader>su', '<cmd>Telescope undo<cr>', { desc = '[S]earch [U]ndo history' })
