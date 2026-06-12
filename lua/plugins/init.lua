-- [[ Plugins via vim.pack (Neovim 0.12 native package manager) ]]
--
-- Notes vs lazy.nvim:
--  * No dependency resolution -> every transitive dependency is listed explicitly.
--  * No build hooks -> handled by the PackChanged autocmd below (registered BEFORE add).
--  * Eager loading -> filetype-specific plugins self-gate via their own ftplugins.

-- Build hooks: run a shell command (carried in spec.data.build) on install/update,
-- and re-run :TSUpdate for treesitter parsers.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('plugins-build', { clear = true }),
  callback = function(ev)
    local d = ev.data
    if d.kind == 'delete' then
      return
    end

    if d.spec.name == 'nvim-treesitter' then
      vim.schedule(function()
        vim.cmd 'TSUpdate'
      end)
      return
    end

    local build = d.spec.data and d.spec.data.build
    if build then
      vim.notify(('Building %s: %s'):format(d.spec.name, build), vim.log.levels.INFO)
      vim.system(vim.split(build, ' ', { trimempty = true }), { cwd = d.path }, function(out)
        if out.code ~= 0 then
          vim.schedule(function()
            vim.notify(('Build failed for %s:\n%s'):format(d.spec.name, out.stderr or ''), vim.log.levels.ERROR)
          end)
        end
      end)
    end
  end,
})

vim.pack.add {
  -- Libraries / shared dependencies (lazy.nvim used to pull these transitively)
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },

  -- LSP tooling
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/j-hui/fidget.nvim' },

  -- Editor / UI
  { src = 'https://github.com/navarasu/onedark.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  { src = 'https://github.com/HiPhish/rainbow-delimiters.nvim' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/folke/zen-mode.nvim' },
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },

  -- Telescope + extensions
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = '0.1.x' },
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim', data = { build = 'make' } },
  { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },

  -- Treesitter (modern `main` branch; parsers compiled via :TSUpdate)
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },

  -- Files / navigation
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
  { src = 'https://github.com/kevinhwang91/nvim-bqf' },
  { src = 'https://github.com/junegunn/fzf', data = { build = './install --bin' } },
  { src = 'https://github.com/junegunn/fzf.vim' },

  -- Git
  { src = 'https://github.com/sindrets/diffview.nvim' },

  -- Formatting / LSP extras
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/barreiroleo/ltex-extra.nvim' },
  { src = 'https://github.com/folke/trouble.nvim' },
  { src = 'https://github.com/rmagatti/auto-session' },
  { src = 'https://github.com/nvim-pack/nvim-spectre' },

  -- Editing
  { src = 'https://github.com/SirVer/ultisnips' },
  { src = 'https://github.com/voldikss/vim-floaterm' },
  { src = 'https://github.com/mg979/vim-visual-multi' },
  { src = 'https://github.com/tpope/vim-sleuth' },

  -- Filetype specific (self-gate on filetype)
  { src = 'https://github.com/lervag/vimtex' },
  { src = 'https://github.com/voldikss/vim-mma' },
  { src = 'https://github.com/goerz/jupytext.nvim' },

  -- Notebooks / Python helpers handled above

  -- Disabled (kept for easy re-enable):
  -- { src = 'https://github.com/zbirenbaum/copilot.lua' },
  -- { src = 'https://github.com/CopilotC-Nvim/CopilotChat.nvim', data = { build = 'make tiktoken' } },
  -- { src = 'https://github.com/subnut/nvim-ghost.nvim' },
}

-- Run each plugin's setup module. Plugins with no Lua setup (devicons, nui,
-- bqf, fzf/fzf.vim, diffview, ltex-extra, vim-mma, vim-sleuth, vim-visual-multi)
-- work just by being on the runtimepath, so they are omitted here.
local modules = {
  'onedark',
  'gitsigns',
  'which-key',
  'mini',
  'indent-blankline',
  'rainbow-delimiters',
  'todo-comments',
  'render-markdown',
  'telescope',
  'treesitter',
  'neo-tree',
  'harpoon',
  'undotree',
  'conform',
  'trouble',
  'auto-session',
  'spectre',
  'jupytext',
  'ultisnips',
  'vim-floaterm',
  'vimtex',
  'zen-mode',
}

for _, m in ipairs(modules) do
  require('plugins.' .. m)
end

-- vim: ts=2 sts=2 sw=2 et
