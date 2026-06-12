-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
        ['l'] = 'open',
      },
    },
  },
}

vim.keymap.set('n', '<C-b>', '<CMD>Neotree toggle reveal=true position=float<CR>', { desc = 'NeoTree reveal', silent = true })
vim.keymap.set('n', '<C-g>', '<CMD>Neotree toggle source=git_status reveal=true position=float<CR>', { desc = 'NeoTree git status', silent = true })
