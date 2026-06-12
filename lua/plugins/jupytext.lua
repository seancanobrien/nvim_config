require('jupytext').setup {
  jupytext = '/home/sean/.local/python_env_for_packages/env/bin/jupytext',
  format = 'markdown',
  update = true,
  sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
  autosync = true,
  handle_url_schemes = true,
}
