local M = {}

local utils = require("man-pages.utils")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local function create_previewer()
  return previewers.new_buffer_previewer({
    title = "Man Page",
    get_buffer_by_name = function(_, entry)
      return entry.value.name .. "(" .. entry.value.section .. ")"
    end,
    define_preview = function(self, entry)
      local content = utils.get_man_page(entry.value.name, entry.value.section)
      if content then
        local lines = utils.format_for_preview(content)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "man")
      else
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"Man page not found"})
      end
    end,
  })
end

function M.man_pages(opts)
  opts = opts or {}
  
  local pages = utils.get_available_man_pages()
  
  if #pages == 0 then
    vim.notify("No man pages found", vim.log.levels.WARN)
    return
  end
  
  pickers.new(opts, {
    prompt_title = "Man Pages",
    finder = finders.new_table({
      results = pages,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name .. " " .. entry.description,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = create_previewer(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("Man " .. selection.value.section .. " " .. selection.value.name)
        end
      end)
      return true
    end,
  }):find()
end

function M.search_man_page(opts)
  opts = opts or {}
  
  vim.ui.input({ prompt = "Enter man page name: " }, function(input)
    if not input or input == "" then
      return
    end
    
    local content = utils.get_man_page(input)
    if content then
      vim.cmd("Man " .. input)
    else
      local pages = utils.get_available_man_pages()
      local filtered = {}
      
      for _, page in ipairs(pages) do
        if page.name:lower():find(input:lower(), 1, true) then
          table.insert(filtered, page)
        end
      end
      
      if #filtered == 0 then
        vim.notify("No man pages found matching: " .. input, vim.log.levels.WARN)
        return
      elseif #filtered == 1 then
        vim.cmd("Man " .. filtered[1].section .. " " .. filtered[1].name)
      else
        pickers.new(opts, {
          prompt_title = "Man Pages - " .. input,
          finder = finders.new_table({
            results = filtered,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.name .. " " .. entry.description,
              }
            end,
          }),
          sorter = conf.generic_sorter(opts),
          previewer = create_previewer(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                vim.cmd("Man " .. selection.value.section .. " " .. selection.value.name)
              end
            end)
            return true
          end,
        }):find()
      end
    end
  end)
end

return M