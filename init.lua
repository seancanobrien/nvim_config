vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- The venv which holds relevant python packages
vim.g.python3_host_prog = '/home/sean/.local/python_env_for_packages/env/bin/python'

-- [[ Editor configuration ]]
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- [[ Plugins (managed by vim.pack) ]]
require 'plugins'

-- [[ LSP + native completion ]] (needs mason on the runtimepath, so load after plugins)
require 'config.lsp'

-- [[ Filetype specific ]]
require 'ft.csv'
require 'ft.gap'
require 'ft.latex'
require 'ft.markdown'
require 'ft.mathematica'
require 'ft.maxima'
require 'ft.zsh'

-- [[ General purpose ]]
require 'lib.useful_shortcuts'

-- vim: ts=2 sts=2 sw=2 et
