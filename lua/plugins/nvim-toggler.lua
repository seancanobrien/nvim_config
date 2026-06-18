-- Toggle opposite words/symbols under the cursor (true<->false, ==<->!=, etc.).
-- Defaults are sensible; this also keeps the built-in <leader>i keymap
-- (normal + visual) bound to nvim-toggler.toggle().
require('nvim-toggler').setup {
  remove_default_keybinds = false,
}
