-- Relative line numbers using only easy-to-reach digits (skips 6/7/8/9),
-- so vertical jumps like 12k never need an awkward keystroke.
require('comfy-line-numbers').setup {
  -- Don't take over special-purpose windows.
  hidden_file_types = { 'undotree', 'neo-tree' },
  hidden_buffer_types = { 'terminal', 'nofile' },
}
