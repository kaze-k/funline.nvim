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

## Setup

- [config](https://github.com/kaze-k/funline.nvim/blob/main/lua/funline/config.lua)

```lua
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
  specialtypes = {},
  highlight = { link = "StatusLine" },
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

> You can also refer to [funline-base.nvim](https://github.com/kaze-k/funline-base.nvim) for custom configuration.

<p align="center">
  <a href="https://github.com/kaze-k/funline.nvim/blob/main/LICENSE"
    ><img
      src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=282a36&colorB=c678dd"
  /></a>
</p>

