-- Function to open kitty in the current working directory
local function open_kitty_here()
  local cwd = vim.fn.getcwd()
  vim.fn.jobstart({ 'kitty', '--directory', cwd }, { detach = true })
end

-- Expose as :KittyHere command
vim.api.nvim_create_user_command('KittyHere', open_kitty_here, {})

-- Then set the keymap
vim.keymap.set('n', '<leader>kt', open_kitty_here, { desc = 'Open kitty in cwd' })
