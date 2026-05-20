# Filetype indentation

Put language-specific indentation rules in this directory using Neovim's
standard filetype plugin names:

```text
after/ftplugin/lua.lua
after/ftplugin/python.lua
after/ftplugin/go.lua
```

Each file is loaded only for buffers with that `filetype`, after Neovim's
default filetype settings and plugin settings have run.

Example:

```lua
require('custom.indent').set {
  tabstop = 4,
  shiftwidth = 4,
  softtabstop = 4,
  expandtab = true,
}
```

For tab-indented languages:

```lua
require('custom.indent').set {
  tabstop = 4,
  shiftwidth = 4,
  softtabstop = 0,
  expandtab = false,
}
```

Check the current buffer's filetype with:

```vim
:set filetype?
```
