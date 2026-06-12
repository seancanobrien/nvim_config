-- This is only for my specific group theoretical outputs

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'csv',
  callback = function()
    vim.api.nvim_create_user_command('QSearch', function(opts)
      local input = opts.args

      local out = {}
      local i = 1
      while i <= #input do
        local c = input:sub(i, i)

        if c:match '%a' then
          local next_char = input:sub(i + 1, i + 1)

          if next_char == '-' then
            -- a- means a^-1
            table.insert(out, c .. '\\^-1')
            i = i + 1
          elseif next_char == '?' then
            -- a? means either a or a^-1
            table.insert(out, '\\v(' .. c .. '|' .. c .. '\\^-1)')
            i = i + 1
          else
            table.insert(out, c)
          end
        elseif c == '.' and input:sub(i, i + 1) == '.*' then
          table.insert(out, '.*')
          i = i + 1
        end

        i = i + 1
      end

      -- join with regex for * separator (except for wildcards)
      local pattern_parts = {}
      for _, piece in ipairs(out) do
        if piece == '.*' then
          table.insert(pattern_parts, '.*')
        else
          table.insert(pattern_parts, piece)
        end
      end

      local pattern = table.concat(pattern_parts, '\\s*\\*\\s*')

      -- set search register
      vim.fn.setreg('/', pattern)
      vim.cmd 'normal! n'
    end, { nargs = 1 })
  end,
})
