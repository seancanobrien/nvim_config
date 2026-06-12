-- Floating terminal
-- vim.api.nvim_set_keymap('n', '<leader>bb', '<cmd>FloatermToggle --width=0.9 --height=0.9<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bb', '<cmd>FloatermNew --width=0.9 --height=0.9<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bk', '<cmd>FloatermKill<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bn', '<cmd>FloatermNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bp', '<cmd>FloatermPrev<CR>', { noremap = true, silent = true })
