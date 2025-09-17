local M = {}

function M.get_man_page(name, section)
  local cmd
  if section then
    cmd = string.format("man %s %s 2>/dev/null", section, name)
  else
    cmd = string.format("man %s 2>/dev/null", name)
  end
  
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  
  local result = handle:read("*a")
  handle:close()
  
  if result == "" then
    return nil
  end
  
  return result
end

function M.get_available_man_pages()
  local cmd = "man -k . 2>/dev/null | head -1000"
  local handle = io.popen(cmd)
  if not handle then
    return {}
  end
  
  local result = handle:read("*a")
  handle:close()
  
  local pages = {}
  local seen = {}
  
  for line in result:gmatch("[^\r\n]+") do
    local name, section, description = line:match("^([^%s]+)%s*%((%d+[^%)]*%)%)%s*%-%s*(.*)$")
    if name and section and description then
      local key = name .. "(" .. section:gsub("[%(%)]", "") .. ")"
      if not seen[key] then
        seen[key] = true
        table.insert(pages, {
          name = name,
          section = section:gsub("[%(%)]", ""),
          description = description:sub(1, 80),
          display = string.format("%-20s %s", key, description:sub(1, 60))
        })
      end
    end
  end
  
  return pages
end

function M.format_for_preview(content)
  if not content then
    return {}
  end
  
  local lines = {}
  for line in content:gmatch("[^\r\n]*") do
    line = line:gsub("\x1b%[[%d;]*m", "")
    line = line:gsub("\x08.", "")
    table.insert(lines, line)
  end
  
  return lines
end

return M