-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- To speed up tree-sitter updating and tree inspection
vim.keymap.set('n', '<leader>rtu', '<CMD>TSUpdate<CR>', { desc = 'Tree-Sitter Update' })
vim.keymap.set('n', '<leader>rti', '<CMD>InspectTree<CR>', { desc = 'Tree-Sitter Inspect Tree' })

-- Replace all ". " (period whitespace) with ".\n" (period newline). Useful in tex.
vim.keymap.set('n', '<leader>r.', [[:%s/\. /\.\r/g<CR>]], { noremap = true, silent = true, desc = "Replace '. ' with '.\\n'" })

-- Paste/delete without changing buffer
vim.keymap.set('v', '<Leader>p', '"_dP', { desc = '[P]aste and keep register', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>d', '"_d', { desc = '[D]elete to black hole', noremap = true, silent = true })
vim.keymap.set('v', '<Leader>d', '"_d', { desc = '[D]elete to black hole', noremap = true, silent = true })

-- Clear search highlight on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- NOTE: native `[d`/`]d` jump between diagnostics on 0.11+, so we don't remap them.
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- vim: ts=2 sts=2 sw=2 et
