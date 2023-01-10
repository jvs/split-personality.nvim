local list = require("split-personality.circular-list")
local switcher = require("split-personality.switcher")

local M = {}

local windows = {}
local win_getid = vim.fn.win_getid


local function cleanup()
  local valid_windows = {}
  local valid_buffers = {}

  for _, winid in pairs(vim.api.nvim_list_wins()) do
    valid_windows[winid] = true
  end

  for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      valid_buffers[bufnr] = true
    end
  end

  local cleaned_windows = {}
  for winid, buffers in pairs(windows) do
    if valid_windows[winid] then
      local cleaned_buffers = {}
      for _, bufnr in pairs(buffers) do
        if valid_buffers[bufnr] then
          table.insert(cleaned_buffers, bufnr)
        end
      end
      cleaned_windows[winid] = cleaned_buffers
    end
  end

  windows = cleaned_windows
end

local function is_reachable(bufnr)
  for _, buffers in pairs(windows) do
    for _, reachable in pairs(buffers) do
      if bufnr == reachable then
        return true
      end
    end
  end

  return false
end

local function set_buffers(buffers)
  windows[win_getid()] = buffers
end

local function switch_buffers()
  local bufnr = M.get_buffers()[1]

  if bufnr ~= nil then
    vim.cmd(string.format("b%d", bufnr))
  end
end

function M.close_buffer()
  local buffers = M.get_buffers()
  local buffer = buffers[1]
  set_buffers(list.remove(buffers, buffer))
  switch_buffers()

  if not is_reachable(buffer) then
    vim.cmd(string.format('bd! %d', buffer))
  end
end

function M.get_buffers()
  cleanup()
  local winid = win_getid()

  if windows[winid] == nil then
    windows[winid] = list.new()
  end

  return windows[winid]
end

function M.goto_buffer(buffer)
  if buffer ~= nil then
    set_buffers(list.prepend(M.get_buffers(), buffer))
    switch_buffers()
  end
end

function M.goto_next_buffer()
  set_buffers(list.shift_right(M.get_buffers()))
  switch_buffers()
end

function M.goto_previous_buffer()
  set_buffers(list.shift_left(M.get_buffers()))
  switch_buffers()
end

function M.on_enter(ev)
  set_buffers(list.prepend(M.get_buffers(), ev.buf))
end

function M.show_switcher()
  cleanup()

  local winid = win_getid()
  local buffers = windows[winid]

  switcher.show_switcher(buffers, {
    on_change = function(item)
      local bufnr = item.bufnr
      if bufnr ~= nil then
        vim.api.nvim_win_set_buf(winid, bufnr)
      end
    end,

    on_close = function()
      local bufnr = buffers[1]
      if bufnr ~= nil then
        vim.api.nvim_win_set_buf(winid, bufnr)
      end
    end,

    on_submit = function(item)
      M.goto_buffer(item.bufnr)
    end,
  })
end

function M.setup() end

return M
