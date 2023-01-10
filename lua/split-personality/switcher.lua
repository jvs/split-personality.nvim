local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
local path_separator

if is_windows then
  path_separator = "\\"
else
  path_separator = "/"
end


local function segment_path(path)
  local pattern = string.format("([^%s]+)", path_separator)
  local segments = {}
  local _ = string.gsub(path, pattern, function(c)
    segments[#segments + 1] = c
  end)
  return segments
end


local function strip_common_prefixes(fullpaths)
  local segmented_paths = {}
  for idx, fullpath in pairs(fullpaths) do
    segmented_paths[idx] = segment_path(fullpath)
  end

  local num_found = 0
  local continue = true
  while continue do
    local current_segment = nil
    for _, segmented_path in pairs(segmented_paths) do
      if num_found + 1 >= #segmented_path then
        continue = false
        break
      elseif continue then
        if current_segment == nil then
          current_segment = segmented_path[num_found + 1]
        elseif current_segment ~= segmented_path[num_found + 1] then
          continue = false
          break
        end
      end
    end
    if continue then
      num_found = num_found + 1
    end
  end

  local results = {}
  for idx, segmented_path in pairs(segmented_paths) do
    local suffix = nil
    for i = num_found + 1, #segmented_path do
      if suffix == nil then
        suffix = segmented_path[i]
      else
        suffix = suffix .. path_separator .. segmented_path[i]
      end
    end
    results[idx] = suffix
  end
  return results
end



M.show_switcher = function(buffers, opts)
  local Menu = require("nui.menu")

  local fullpaths = {}
  for idx, bufnr in pairs(buffers) do
    fullpaths[idx] = vim.api.nvim_buf_get_name(bufnr)
  end

  local items = {}
  for idx, shortpath in pairs(strip_common_prefixes(fullpaths)) do
    items[idx] = Menu.item(shortpath, { bufnr = buffers[idx] })
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
