if vim.g.loaded_split_personality == 1 then
  return
end
vim.g.loaded_split_personality = 1

local split_personality = require("split-personality")

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  callback = function(ev)
    split_personality.on_enter(ev)
  end,
})

local has_commanderly, commanderly = pcall(require, "commanderly")

if has_commanderly then
  commanderly.add_commands({
    {
      title = "Close Current File",
      id = "split_personality_close",
      desc = "Close the current file.",
      run = function()
        split_personality.close_buffer()
      end,
      keywords = "split-personality",
      replace = true,
    },
    {
      title = "Show Next File",
      id = "split_personality_next",
      desc = "Show the next file in the current split.",
      run = function()
        split_personality.goto_next_buffer()
      end,
      keywords = "split-personality",
      replace = true,
    },
    {
      title = "Show Previous File",
      id = "split_personality_previous",
      desc = "Show the previous file in the current split.",
      run = function()
        split_personality.goto_previous_buffer()
      end,
      keywords = "split-personality",
      replace = true,
    },
    {
      title = "Show Buffer Switcher",
      id = "split_personality_show_switcher",
      desc = "Switch between buffers in the current split.",
      run = function()
        split_personality.show_switcher()
      end,
      keywords = "split-personality",
      replace = true,
    },
  })
end
