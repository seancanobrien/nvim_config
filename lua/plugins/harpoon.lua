-- File navigation
local harpoon = require 'harpoon'
harpoon:setup {}

vim.keymap.set('n', '<leader>al', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon Quick Menu' })

vim.keymap.set('n', '<leader>aa', function()
  harpoon:list():add()
end, { desc = 'Add File to Harpoon' })

vim.keymap.set('n', '<C-T>1', function()
  harpoon:list():select(1)
end)
vim.keymap.set('n', '<C-T>2', function()
  harpoon:list():select(2)
end)
vim.keymap.set('n', '<C-T>3', function()
  harpoon:list():select(3)
end)
vim.keymap.set('n', '<C-T>4', function()
  harpoon:list():select(4)
end)
vim.keymap.set('n', '<C-T>5', function()
  harpoon:list():select(5)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<C-S-P>', function()
  harpoon:list():prev()
end)
vim.keymap.set('n', '<C-S-N>', function()
  harpoon:list():next()
end)
