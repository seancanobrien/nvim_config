-- Markdown -> HTML (pandoc) with BrowserSync live preview.
-- Off by default. Toggle per buffer with :MarkdownBuildToggle or <leader>ll
-- (mirrors VimTeX's <localleader>ll). Output goes to build/ relative to
-- Neovim's working directory.

local browsersync_job = nil
local builds = {} -- bufnr -> { outfile = <absolute path>, opened = <bool> }
local augroup = vim.api.nvim_create_augroup('markdown_build', { clear = true })

local function start_browsersync(builddir)
  if browsersync_job ~= nil then
    return -- already running
  end
  local job = vim.fn.jobstart({
    'browser-sync',
    'start',
    '--server',
    builddir,
    '--files',
    builddir .. '/*.html',
    '--no-open', -- don't spawn another Firefox, we control that
  }, {
    detach = false, -- tie lifecycle to nvim
    on_exit = function(id)
      if browsersync_job == id then
        browsersync_job = nil
      end
    end,
  })
  if job <= 0 then
    vim.notify('Could not start browser-sync', vim.log.levels.ERROR)
    return
  end
  browsersync_job = job
end

local function stop_browsersync()
  if browsersync_job ~= nil then
    vim.fn.jobstop(browsersync_job)
    browsersync_job = nil
  end
end

local function preview_url(outfile)
  return 'http://localhost:3000/' .. vim.fn.fnamemodify(outfile, ':t')
end

local function build(bufnr)
  local state = builds[bufnr]
  if not state then
    return
  end
  local infile = vim.api.nvim_buf_get_name(bufnr)
  vim.fn.mkdir(vim.fn.fnamemodify(state.outfile, ':h'), 'p')

  vim.fn.jobstart({ 'pandoc', infile, '-s', '-o', state.outfile, '-c', 'style.css' }, {
    on_exit = function(_, code)
      if builds[bufnr] ~= state then
        return -- toggled off while pandoc was running
      end
      if code ~= 0 then
        vim.notify('Pandoc failed for ' .. vim.fn.fnamemodify(infile, ':~:.'), vim.log.levels.ERROR)
        return
      end
      start_browsersync(vim.fn.fnamemodify(state.outfile, ':h'))
      -- Open Firefox on the first successful build after enabling
      if not state.opened then
        state.opened = true
        vim.fn.jobstart({ 'firefox', preview_url(state.outfile) }, { detach = true })
      end
    end,
  })
end

local function disable(bufnr, quiet)
  if not builds[bufnr] then
    return
  end
  builds[bufnr] = nil
  vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }

  -- BrowserSync serves every enabled buffer, so only stop it with the last one
  local stopped = false
  if next(builds) == nil and browsersync_job ~= nil then
    stop_browsersync()
    stopped = true
  end
  if not quiet then
    vim.notify('Markdown auto-build OFF' .. (stopped and ' (browser-sync stopped)' or ''))
  end
end

local function enable(bufnr)
  local infile = vim.api.nvim_buf_get_name(bufnr)
  if infile == '' then
    vim.notify('Markdown auto-build: save the buffer to a file first', vim.log.levels.WARN)
    return
  end
  local outfile = vim.fs.joinpath(vim.fn.getcwd(), 'build', vim.fn.fnamemodify(infile, ':t:r') .. '.html')
  builds[bufnr] = { outfile = outfile, opened = false }

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    buffer = bufnr,
    callback = function()
      build(bufnr)
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      disable(bufnr, true)
    end,
  })

  vim.notify(('Markdown auto-build ON: HTML goes to %s (live at %s)'):format(vim.fn.fnamemodify(outfile, ':~:.'), preview_url(outfile)))
  build(bufnr)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('markdown_build_setup', { clear = true }),
  pattern = 'markdown',
  callback = function(args)
    local bufnr = args.buf
    local function toggle()
      if builds[bufnr] then
        disable(bufnr)
      else
        enable(bufnr)
      end
    end
    vim.api.nvim_buf_create_user_command(bufnr, 'MarkdownBuildToggle', toggle, {
      desc = 'Toggle pandoc HTML build + live preview for this buffer',
    })
    vim.keymap.set('n', '<leader>ll', toggle, { buffer = bufnr, desc = 'Toggle Markdown HTML build' })
  end,
})

-- Stop BrowserSync when Neovim quits
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = augroup,
  callback = stop_browsersync,
})
