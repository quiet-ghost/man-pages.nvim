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
    winblend = 50,
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

   vim.api.nvim_create_user_command("Man", function(opts)
     local name = opts.args
     if name and name ~= "" then
       -- Try to open directly with Neovim's :Man
       local success = pcall(vim.cmd, "Man " .. name)
       if not success then
         -- If failed, open the picker with the name pre-filled
         require("man-pages.telescope").man_pages(vim.tbl_extend("force", M.config.telescope, {
           default_text = name,
         }))
       end
     else
       -- No name provided, open the picker
       require("man-pages.telescope").man_pages(M.config.telescope)
     end
   end, { nargs = "?", desc = "Open man page directly or search with Telescope" })
end

return M