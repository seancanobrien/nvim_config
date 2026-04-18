vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/?.lua'
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/lua/custom/tools/?.lua'
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/lua/custom/filetype_specific/?.lua'
package.path = package.path .. ';' .. vim.fn.stdpath 'config' .. '/lua/custom/general/?.lua'

-- The venv which holds relevant python packages
vim.g.python3_host_prog = '/home/sean/.local/python_env_for_packages/env/bin/python'

-- [[ Custom Scripts etc ]]
require 'custom-tools'

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'
