# man-pages.nvim

A Neovim plugin that integrates man pages with Telescope, allowing you to quickly search and preview man pages without leaving your editor.

## Features

- Fuzzy search man pages using Telescope
- Preview man pages directly in Telescope
- Quick access with customizable keybindings
- Browse all available man pages
- Direct search by name

## Requirements

- Neovim >= 0.7
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Unix-like system with `man` command available

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "quiet-ghost/man-pages.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("man-pages").setup({
      keymaps = {
        search = "<leader>mp",  -- Search for a specific man page
        browse = "<leader>mb",  -- Browse all man pages
      },
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "quiet-ghost/man-pages.nvim",
  requires = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("man-pages").setup()
  end
}
```

## Usage

### Default Keybindings

- `<leader>mp` - Search for man pages (type to filter)
- `<leader>mb` - Browse all available man pages

### Commands

- `:ManSearch [name]` - Search for a man page by name
- `:ManBrowse` - Browse all available man pages

### Workflow

1. Press `<leader>mp` to open the search prompt
2. Type the name of the command/function you want documentation for
3. If exact match is found, it opens directly
4. If multiple matches, select from Telescope picker
5. Preview appears automatically in Telescope
6. Press `<Enter>` to open the full man page in Neovim

## Configuration

```lua
require("man-pages").setup({
  keymaps = {
    search = "<leader>mp",  -- Set to false to disable
    browse = "<leader>mb",  -- Set to false to disable
  },
})
```

## How It Works

The plugin:

1. Uses the system's `man -k` command to get available man pages
2. Integrates with Telescope for fuzzy finding
3. Formats man page output for clean preview
4. Opens selected pages using Neovim's built-in `:Man` command
