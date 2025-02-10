local M = {}

local config = require("funline.config")
local utils = require("funline.utils")
local Funline = require("funline.core")

local function command()
  vim.api.nvim_create_user_command("FunlineToggle", function() Funline.toggle() end, {})
  vim.api.nvim_create_user_command("FunlineOpen", function() Funline.open() end, {})
  vim.api.nvim_create_user_command("FunlineClose", function() Funline.close() end, {})
  vim.api.nvim_create_user_command("FunlineStop", function() Funline.stop() end, {})
  vim.api.nvim_create_user_command("FunlineStart", function() Funline.start() end, {})
  vim.api.nvim_create_user_command("FunlineReload", function() Funline.reload() end, {})
end

local function reload(options)
  local group = vim.api.nvim_create_augroup("FunlineReload", { clear = true })

  vim.api.nvim_create_autocmd("Colorscheme", {
    group = group,
    callback = function() M.setup(options) end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    callback = function() M.setup(options) end,
  })
end

local setup_config = config.default

function M.setup(opts)
  setup_config = utils.merge_config(opts or {}, config.default)
  Funline:new(setup_config)
  command()
  reload(setup_config)
end

M.toggle = Funline.toggle
M.open = Funline.open
M.close = Funline.close
M.stop = Funline.stop
M.start = Funline.start
M.reload = Funline.reload

return M
