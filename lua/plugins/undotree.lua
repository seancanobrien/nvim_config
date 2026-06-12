-- Native undotree (Neovim distributed plugin, replaces mbbill/undotree).
-- Shipped as an optional runtime plugin; load it explicitly. `silent!` keeps
-- startup quiet on builds that don't ship `nvim.undotree` yet (pre-merge dev
-- builds) -- update Neovim to get the :Undotree command.
vim.cmd 'silent! packadd nvim.undotree'

-- Toggle the undo-tree window. Moving the cursor in it changes the undo state.
vim.keymap.set('n', '<leader>uu', '<cmd>Undotree<CR>', { desc = 'Toggle [u]ndotree' })
