-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- modular approach: using `require 'path/name'` will
  -- include a plugin definition from file lua/path/name.lua

  -- 'Built in' plugins
  require 'kickstart/plugins/gitsigns',
  require 'kickstart/plugins/which-key',
  require 'kickstart/plugins/telescope',
  require 'kickstart/plugins/lspconfig',
  require 'kickstart/plugins/conform',
  require 'kickstart/plugins/cmp',
  require 'kickstart/plugins/onedark',
  require 'kickstart/plugins/todo-comments',
  require 'kickstart/plugins/mini',
  require 'kickstart/plugins/treesitter',
  require 'kickstart/plugins/neo-tree',

  -- Custom plugins
  require 'custom/plugins/auto-session',
  require 'custom/plugins/bqf',
  require 'custom/plugins/Comment',
  require 'custom/plugins/harpoon',
  require 'custom/plugins/indent-blankline',
  require 'custom/plugins/rainbow-delimiters',
  require 'custom/plugins/trouble',
  require 'custom/plugins/spectre',
  require 'custom/plugins/telescope-undo',
  require 'custom/plugins/undotree',
  require 'custom/plugins/vim-floaterm',
  require 'custom/plugins/vim-mma',
  require 'custom/plugins/vim-sleuth',
  require 'custom/plugins/vim-unimpaired',
  require 'custom/plugins/vim-visual-multi',
  require 'custom/plugins/zen-mode',
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
