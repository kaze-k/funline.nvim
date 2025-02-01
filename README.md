<p align="center">
  <h1 align="center">funline.nvim</h1>
</p>

<p align="center">
  <a href="https://github.com/kaze-k/funline.nvim/stargazers">
    <img
      alt="Stargazers"
      src="https://img.shields.io/github/stars/kaze-k/funline.nvim?style=for-the-badge&logo=starship&color=c678dd&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/kaze-k/funline.nvim/issues">
    <img
      alt="Issues"
      src="https://img.shields.io/github/issues/kaze-k/funline.nvim?style=for-the-badge&logo=gitbook&color=f0c062&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/kaze-k/funline.nvim/contributors">
    <img
      alt="Contributors"
      src="https://img.shields.io/github/contributors/kaze-k/funline.nvim?style=for-the-badge&logo=opensourceinitiative&color=abcf84&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
</p>

## About

Funline.nvim is a Neovim plugin made for rendering statusline format strings.

It is a customizable plugin, you can put some fun things on your statusline display.

Provides the ability to refresh the statusline at customizable intervals.

It was inspired by [galaxyline](https://github.com/nvimdev/galaxyline.nvim) and [heirline](https://github.com/rebelot/heirline.nvim).

## Requires

- [neovim 0.10.0+](https://github.com/neovim/neovim/releases/tag/v0.10.0)

## Installation

- [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "kaze-k/funline.nvim",
  config = function()
    require("my_statusline") -- your statusline config
  end
}
```

> use [funline-base.nvim](https://github.com/kaze-k/funline-base.nvim) if you happen to be using the same plugin as me.

```lua
{
  "kaze-k/funline-base.nvim",
  dependencies = { "kaze-k/funline.nvim" },
  config = function()
    require("funline-base").setup()
  end
}
```

## Commands

- `:FunlineToggle` open/close funline
- `:FunlineOpen` open funline
- `:FunlineClose` close funline
- `:FunlineStop` stop funline refresh
- `:FunlineStart` start funline refresh
- `:FunlineReload` reload funline

## API

- `require("funline").toggle()` open/close funline
- `require("funline").open()` open funline
- `require("funline").close()` close funline
- `require("funline").stop()` stop funline refresh
- `require("funline").start()` start funline refresh
- `require("funline").reload()` reload funline

## Setup

- [config](https://github.com/kaze-k/funline.nvim/blob/main/lua/funline/config.lua)

```lua
-- line config
---@class Line
---@field left? table
---@field mid? table
---@field right? table

---line highlights
---@class Highlights
---@field left? vim.api.keyset.highlight
---@field mid? vim.api.keyset.highlight
---@field right? vim.api.keyset.highlight

-- refresh config
---@class Refresh
---@field timeout? number
---@field interval? number

-- config
---@class Config
---@field statusline? Line
---@field specialline? Line
---@field highlights? Highlights
---@field specialtypes? table
---@field refresh? Refresh
---@field handle_update? function
require("funline").setup({
  statusline = {
    left = {...},
    mid = {...},
    right = {...},
  },
  specialline = {
    left = {...},
    mid = {...},
    right = {...},
  },
  highlights = {
    left = {...},
    mid = {...},
    right = {...},
  },
  specialtypes = {},
  refresh = {
    timeout = 0,
    interval = 1000,
  },
  -- when is the control updated
  handle_update = function(update)
    if ... then
      update(true)
    else
      update(false)
    end
  end,
})
```

## Component Examples

All default properties of the component.

```lua
-- default props
---@class Component.Props
---@field condition boolean
---@field icon string
---@field provider string
---@field padding { left: string, right: string }
---@field hl vim.api.keyset.highlight
local DEFAULT_PROPS = {
  condition = true,
  icon = "",
  provider = "",
  padding = { left = "", right = "" },
  hl = {},
}
```

> All properties are optional because funline automatically adds default values.

- dynamic

```lua
M.example = function(ctx)
  if ... then
    ctx.refresh(1000) -- refresh every 1000ms
  else
    ctx.done() -- stop this component refresh
  end

  return {
    condition = true, -- whether to display
    icon = "😉", -- fun icon
    provider = "Hello, World!", -- display text
    padding = { left = " ", right = " " }, -- padding
    hl = { fg = "#ff0000", bg = "#00ff00", bold = true }, -- highlight
  }
end
```

- static

```lua
M.example = {
  condition = true, -- whether to display
  icon = "😉", -- fun icon
  provider = "Hello, World!", -- display text
  padding = { left = " ", right = " " }, -- padding
  hl = { fg = "#ff0000", bg = "#00ff00", bold = true }, -- highlight
}
```

> You can also refer to [funline-base.nvim](https://github.com/kaze-k/funline-base.nvim) for custom configuration.

<p align="center">
  <a href="https://github.com/kaze-k/funline.nvim/blob/main/LICENSE"
    ><img
      src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=282a36&colorB=c678dd"
  /></a>
</p>

