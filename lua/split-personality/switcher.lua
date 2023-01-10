local strings = require("plenary.strings")
local utils = require("split-personality.utils")

local M = {}

local function create_element(path, bufnr)
  local basename = utils.basename(path)
  local extension = utils.extension(path)
  local icon = " "
  local highlight = "SplitPersonalityFileIcon"

  local success, web_devicons = pcall(require, "nvim-web-devicons")
  if success then
    local devicon, hl = web_devicons.get_icon(basename, extension, { default = true })
    icon = devicon or icon
    highlight = hl or highlight
  end

  return {
    bufnr = bufnr,
    basename = basename,
    reldir = utils.relative_path(utils.dirname(path, true)),
    icon = icon,
    highlight = highlight,
    width = strings.strdisplaywidth(basename),
  }
end


M.show_switcher = function(buffers, opts)
  local Menu = require("nui.menu")

  local elements = {}
  for _, bufnr in pairs(buffers) do
    local path = vim.api.nvim_buf_get_name(bufnr)
    table.insert(elements, create_element(path, bufnr))
  end

  local column_width = utils.max(elements, "width") + 4

  local items = {}
  for _, element in pairs(elements) do
    local padded = utils.right_pad(element.basename, column_width)
    local label = "  " .. element.icon .. " " .. padded .. element.reldir .. "  "
    table.insert(items, Menu.item(label, element))
  end

  local popup_options = {
    position = "50%",
    border = {
      style = "rounded",
      text = {
        top = " Buffers ",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    }
  }

  local menu = Menu(popup_options, {
    lines = items,
    min_width = 40,
    max_width = 80,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_change = opts.on_change,
    on_close = opts.on_close,
    on_submit = opts.on_submit,
  })

  menu:mount()
end

return M
