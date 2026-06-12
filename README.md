# Neovim config

A personal, modular Neovim configuration targeting **Neovim 0.12+**. It leans on
Neovim's built-in features rather than plugins wherever possible:

* Plugins are managed by the native **`vim.pack`** package manager (no
  `lazy.nvim`).
* Completion is **native** (`vim.lsp.completion` + `'complete'`) — no `nvim-cmp`.
* LSP servers are configured with native **`vim.lsp.config` / `vim.lsp.enable`**
  — no `nvim-lspconfig`.
* Commenting, diagnostic/quickfix/buffer navigation, rename/code-action/
  references and symbol jumps all use Neovim's built-in maps (`gc`, `]d`/`[d`,
  `]q`/`[q`, `]b`/`[b`, `grn`/`gra`/`grr`/`gri`/`gO`).

It started life as a fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
but has since been restructured and trimmed down.

## Requirements

* **Neovim 0.12 or newer.** This config uses APIs that do not exist on 0.11
  (`vim.pack`, `vim.o.autocomplete`, `vim.lsp.completion`, `vim.hl.on_yank`, the
  nvim-treesitter `main` branch). The packaged Neovim in most distros is too old
  — use a recent nightly/0.12 build.
* External tools:
  * Core: `git`, `make`, a C compiler (`gcc`/`clang`), `unzip`
  * [`ripgrep`](https://github.com/BurntSushi/ripgrep) and
    [`fd`](https://github.com/sharkdp/fd) for Telescope
  * A clipboard tool (`xclip`/`xsel`/`wl-clipboard`/`win32yank`)
  * A [Nerd Font](https://www.nerdfonts.com/) (icons). Set
    `vim.g.have_nerd_font = false` in `init.lua` if you don't use one.
* Language servers (installed standalone via [`mason`](https://github.com/williamboman/mason.nvim),
  or put them on `PATH` yourself): `lua-language-server`, `basedpyright`,
  `ltex-ls-plus`, `texlab`.
* LaTeX workflow extras: `latexmk`, `latexindent`, `zathura` (for VimTeX),
  plus a `python3` with `jupytext` for `.ipynb` editing.

## Layout

```
init.lua                 -- leader/globals + python host; loads everything below
lua/
  config/
    options.lua          -- vim.opt settings
    keymaps.lua          -- general keymaps
    autocmds.lua         -- yank-highlight + misc autocommands
    lsp.lua              -- native LSP config/enable, LspAttach, native completion, mason
  plugins/
    init.lua             -- PackChanged build hooks + vim.pack.add{...} + per-plugin requires
    <plugin>.lua         -- one module per plugin (the runtime setup)
  ft/                    -- filetype-specific modules (csv, gap, latex, markdown,
                            mathematica, maxima, zsh)
  lib/
    useful_shortcuts.lua -- misc helper commands/maps
```

Load order (`init.lua`): `config.options` → `config.keymaps` → `config.autocmds`
→ `plugins` (installs/loads plugins via `vim.pack`) → `config.lsp` (needs Mason on
the runtimepath) → the `ft.*` and `lib.*` modules.

## Installation

> **Back up** any existing configuration first.

Neovim looks for its config here:

| OS | Path |
| :- | :--- |
| Linux, macOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd) | `%userprofile%\AppData\Local\nvim\` |
| Windows (powershell) | `$env:USERPROFILE\AppData\Local\nvim\` |

Clone this repo into that path, e.g. on Linux/macOS:

```sh
git clone <this-repo-url> "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

Then start Neovim:

```sh
nvim
```

On first launch `vim.pack` clones every plugin and the `PackChanged` build hooks
run automatically (`make` for `telescope-fzf-native`, `./install --bin` for
`fzf`, and `:TSUpdate` to compile Treesitter parsers). Restart once the builds
finish for everything to be available.

> **Note:** a few paths in the config are personal (the `python3_host_prog` in
> `init.lua`, the `latexindent` settings path and `jupytext` binary in
> `lua/config/lsp.lua` / `lua/plugins/jupytext.lua`). Adjust these for your
> machine.

## Managing plugins

Everything lives in `lua/plugins/init.lua`.

* **Add** a plugin: add an entry to the `vim.pack.add{ ... }` list
  (`{ src = 'https://github.com/owner/repo' }`). If it needs a build step, carry
  it in `data = { build = '<shell command>' }`. If it has Lua setup, create
  `lua/plugins/<name>.lua` and add `<name>` to the `modules` require list.
* **Update**: `:lua vim.pack.update()` (review the diff buffer, then `:write` to
  apply). Treesitter parsers update via the `PackChanged` hook; you can also run
  `:TSUpdate` directly.
* **Inspect / health**: `:lua = vim.pack.get()` lists installed plugins;
  `:checkhealth vim.pack` reports status.
* **Remove**: drop it from `vim.pack.add` (and its module), then
  `:lua vim.pack.del({ '<name>' })`.

`vim.pack` has no dependency resolution, so shared libraries (`plenary.nvim`,
`nvim-web-devicons`, `nui.nvim`) are listed explicitly alongside the plugins that
need them.

## Install recipes (Neovim + dependencies)

<details><summary>Ubuntu / Debian</summary>

```sh
sudo apt update
sudo apt install make gcc ripgrep fd-find unzip git xclip curl
# Neovim 0.12+: install a recent build rather than the apt package, e.g.
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
```
</details>

<details><summary>Fedora</summary>

```sh
sudo dnf install -y gcc make git ripgrep fd-find unzip
# install a recent Neovim 0.12+ build (copr/nightly tarball) as above
```
</details>

<details><summary>Arch</summary>

```sh
sudo pacman -S --needed gcc make git ripgrep fd unzip neovim
# ensure the installed neovim is 0.12+ (neovim-nightly-bin from the AUR if needed)
```
</details>

<details><summary>Windows</summary>

Install Neovim 0.12+, plus `git`, `gcc`/`make` (e.g. via MSYS2 or chocolatey:
`choco install -y neovim git ripgrep fd unzip mingw make`) and a clipboard
provider (`win32yank`). `telescope-fzf-native` may need CMake/MSVC; see its
[install docs](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation).
</details>
