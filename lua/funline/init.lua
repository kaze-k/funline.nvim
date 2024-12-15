local config = require("funline.config")
local utils = require("funline.utils")
local Funline = require("funline.funline")

local function setup(opts)
  local merged_config = utils.merge_config(opts or {}, config.default)

  if vim.o.laststatus ~= 0 then
    Funline:new(merged_config)
  end

  vim.api.nvim_create_user_command("FunlineToggle", function() Funline:toggle(merged_config) end, {})
  vim.api.nvim_create_user_command("FunlineOpen", function() Funline:open(merged_config) end, {})
  vim.api.nvim_create_user_command("FunlineClose", function() Funline:close() end, {})
  vim.api.nvim_create_user_command("FunlineStop", function() Funline:stop() end, {})
  vim.api.nvim_create_user_command("FunlineStart", function() Funline:start() end, {})
end

local M = {
  setup = setup,
}

return M
