local M = {}

local function update(list, value, prepend, append)
  local result = {}
  local next_index = 1

  if prepend then
    result[next_index] = value
    next_index = next_index + 1
  end

  for _, other in pairs(list) do
    if other ~= value then
      result[next_index] = other
      next_index = next_index + 1
    end
  end

  if append then
    result[next_index] = value
  end

  return result
end

function M.new()
  return {}
end

function M.prepend(list, value)
  return update(list, value, true, false)
end

function M.remove(list, value)
  return update(list, value, false, false)
end

function M.shift_left(list)
  return update(list, list[1], false, true)
end

function M.shift_right(list)
  return update(list, list[#list], true, false)
end

return M
