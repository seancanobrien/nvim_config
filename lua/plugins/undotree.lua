-- Native undotree (Neovim distributed plugin, replaces mbbill/undotree).
-- Shipped as an optional runtime plugin; load it explicitly. `silent!` keeps
-- startup quiet on builds that don't ship `nvim.undotree` yet (pre-merge dev
-- builds) -- update Neovim to get the :Undotree command.
vim.cmd 'silent! packadd nvim.undotree'

-- Toggle the undo-tree window. Moving the cursor in it changes the undo state.
-- `:Undotree` hardcodes a 30-column window which truncates the timestamps
-- (`YYYY/MM/DD HH:MM:SS`), so call open() directly with a wider window.
vim.keymap.set('n', '<leader>uu', function()
  require('undotree').open { command = '60vnew' }
end, { desc = 'Toggle [u]ndotree' })
