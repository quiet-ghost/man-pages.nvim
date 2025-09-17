local M = {}

function M.get_man_page(name, section)
  local cmd
  if section then
    cmd = string.format("man %s %s 2>/dev/null", section, name)
  else
    cmd = string.format("man %s 2>/dev/null", name)
  end
  
  local result = vim.fn.system(cmd)
  
  if vim.v.shell_error ~= 0 or not result or result == "" then
    return nil
  end
  
  return result
end

function M.get_available_man_pages()
  -- Use man -k as specified in README
  local cmd = "man -k . 2>/dev/null"
  local result = vim.fn.system(cmd)

  if not result or result == "" or vim.v.shell_error ~= 0 then
    -- Fallback: try apropos
    cmd = "apropos . 2>/dev/null"
    result = vim.fn.system(cmd)

    if not result or result == "" or vim.v.shell_error ~= 0 then
      return {}
    end
  end

  local pages = {}
  local seen = {}
  local count = 0

  for line in result:gmatch("[^\r\n]+") do
    if count >= 500 then break end  -- Limit results for performance

    -- Match various man page formats
    -- Format 1: name (section) - description
    -- Format 2: name(section) - description
    -- Format 3: name (section)     - description (with spaces)
    local name, section, description = line:match("^([^%s%(]+)[%s]*%(([^%)]+)%)[%s]*[-–—]+%s*(.*)$")

    if name and section and description then
      -- Clean up section
      section = section:gsub("^%s*(.-)%s*$", "%1")
      local key = name .. "(" .. section .. ")"

      if not seen[key] then
        seen[key] = true
        count = count + 1
        table.insert(pages, {
          name = name,
          section = section,
          description = description:sub(1, 80),
          display = string.format("%-25s %s", key, description:sub(1, 55))
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