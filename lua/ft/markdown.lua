-- Markdown auto-compile + BrowserSync integration
local browsersync_job = nil

-- Start BrowserSync (once per session)
local function start_browsersync(outfile)
  if browsersync_job ~= nil then
    return -- already running
  end
  browsersync_job = vim.fn.jobstart({
    'browser-sync',
    'start',
    '--server',
    'build',
    '--files',
    'build/*.html',
    '--startPath',
    vim.fn.fnamemodify(outfile, ':t'),
    '--no-open', -- don't spawn another Firefox, we control that
  }, {
    detach = false, -- tie lifecycle to nvim
    on_exit = function()
      browsersync_job = nil
    end,
  })

  -- Open in Firefox the first time only
  vim.fn.jobstart({ 'firefox', 'http://localhost:3000/' .. vim.fn.fnamemodify(outfile, ':t') }, { detach = true })
end

-- Compile on save + kick off BrowserSync
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.md',
  callback = function(args)
    local infile = args.file
    local outfile = 'build/' .. vim.fn.fnamemodify(infile, ':t:r') .. '.html'

    -- ensure build directory exists
    vim.fn.mkdir('build', 'p')

    -- run pandoc to convert md -> html
    vim.fn.jobstart({ 'pandoc', infile, '-s', '-o', outfile, '-c', 'style.css' }, {
      on_exit = function(_, code)
        if code == 0 then
          start_browsersync(outfile)
        else
          vim.notify('Pandoc failed for ' .. infile, vim.log.levels.ERROR)
        end
      end,
    })
  end,
})

-- Stop BrowserSync when Neovim quits
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    if browsersync_job ~= nil then
      vim.fn.jobstop(browsersync_job)
    end
  end,
})
