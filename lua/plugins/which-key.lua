-- Useful plugin to show you pending keybinds.
require('which-key').setup()

-- Document existing key chains
require('which-key').add {
  { '<leader>c', desc = '[C]ode' },
  { '<leader>~', desc = '[~]ymbols' },
  { '<leader>r', desc = '[R]ename' },
  { '<leader>s', desc = '[S]earch' },
  { '<leader>w', desc = '[W]orkspace' },
  { '<leader>t', desc = '[T]oggle' },
  { '<leader>h', desc = 'Git [H]unk' },
}
-- visual mode
require('which-key').add {
  '<leader>h',
  desc = 'Git [H]unk',
  mode = 'v',
}
