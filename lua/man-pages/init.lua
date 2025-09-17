local M = {}

M.config = {
  keymaps = {
    search = "<leader>mp",
  },
  telescope = {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
      width = 0.95,
      height = 0.95,
      preview_height = 0.75,
    },
    winblend = 20,
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  if M.config.keymaps.search then
    vim.keymap.set("n", M.config.keymaps.search, function()
      require("man-pages.telescope").man_pages(M.config.telescope)
    end, { desc = "Search man pages" })
  end
  
  vim.api.nvim_create_user_command("ManPages", function()
    require("man-pages.telescope").man_pages(M.config.telescope)
  end, { desc = "Search and browse man pages with Telescope" })
end

return M