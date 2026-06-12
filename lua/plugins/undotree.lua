vim.g.undotree_WindowLayout = 2
vim.api.nvim_set_keymap('n', '<leader>uu', ':UndotreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>uf', ':UndotreeFocus<CR>', { noremap = true, silent = true })
