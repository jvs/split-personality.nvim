local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
local path_separator

if is_windows then
  path_separator = "\\"
else
  path_separator = "/"
end

M.basename = function(path)
  local parts = M.rsplit(path, path_separator, 1)
  return parts[#parts]
end

M.dirname = function(path, keep_separator)
  local parts = M.rsplit(path, path_separator, 1)
  local result = parts[1] or ""

  if keep_separator then
    result = result .. path_separator
  end
  return result
end

M.extension = function(path)
  local parts = M.rsplit(path, ".", 1)
  if #parts == 2 then
    return parts[#parts]
  else
    return ""
  end
end

M.max = function(tab, field)
  local result = nil

  for _, element in pairs(tab) do
    local value

    if field == nil then
      value = element
    else
      value = element[field]
    end

    if result == nil then
      result = value
    else
      result = math.max(result, value)
    end
  end

  return result
end

M.relative_path = function(path, cwd)
  if cwd == nil then
    cwd = vim.loop.cwd()
  end
  if cwd[#cwd] ~= path_separator then
    cwd = cwd .. path_separator
  end
  return M.remove_prefix(path, cwd)
end

M.remove_prefix = function(str, prefix)
  local found_prefix = str:find(prefix, 1, true)

  if found_prefix == 1 then
    return str:sub(#prefix + 1)
  else
    return str
  end
end

M.reverse_table = function(tab)
  local result = {}
  for i = #tab, 1, -1 do
    table.insert(result, tab[i])
  end
  return result
end

M.right_pad = function(str, length, character)
  return str .. string.rep(character or " ", length - #str)
end

M.rsplit = function(str, sep, limit)
  local reverse = string.reverse
  local reversed = M.split(reverse(str), reverse(sep), limit)
  local results = {}
  for i = #reversed, 1, -1 do
    table.insert(results, reverse(reversed[i]))
  end
  return results
end

M.split = function(str, sep, limit)
  if limit ~= nil and limit <= 0 then
    return { str }
  end

  local start_index = 1
  local result = {}

  while true do
    local i, j = str:find(sep, start_index, true)
    if i == nil then
      break
    end
    table.insert(result, str:sub(start_index, i - 1))
    start_index = j + 1
    if limit ~= nil and #result >= limit then
      break
    end
  end

  table.insert(result, str:sub(start_index))
  return result
end

M.split_path = function(path)
  return M.split(path, path_separator)
end


return M
