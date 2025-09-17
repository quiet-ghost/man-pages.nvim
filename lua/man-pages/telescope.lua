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
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Man page not found" })
			end
		end,
	})
end

function M.man_pages(opts)
	opts = opts or {}

	-- Default floating window configuration
	opts = vim.tbl_deep_extend("force", {
		layout_strategy = "horizontal",
		layout_config = {
			prompt_position = "bottom",
			width = 0.85,
			height = 0.9,
			preview_height = 0.6,
			mirror = false,
		},
		winblend = 0,
		border = true,
		borderchars = {
			prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
			results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
			preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},
	}, opts)

	-- Load man pages (with progress notification)
	vim.notify("Loading man pages...", vim.log.levels.INFO)
	local pages = utils.get_available_man_pages()

	if #pages == 0 then
		vim.notify("No man pages found. Checking if 'man -k' works...", vim.log.levels.WARN)
		-- Debug: try to run the command directly
		local test_result = vim.fn.system("man -k . | head -5")
		if test_result and test_result ~= "" then
			vim.notify("Command works but parsing failed. Please report this issue.", vim.log.levels.ERROR)
		else
			vim.notify("'man -k' command failed. Please check your man-db installation.", vim.log.levels.ERROR)
		end
		return
	end

	vim.notify(string.format("Loaded %d man pages", #pages), vim.log.levels.INFO)

	pickers
		.new(opts, {
			prompt_title = " Man Pages",
			results_title = " Available Pages",
			preview_title = " Preview",
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
		})
		:find()
end

return M
