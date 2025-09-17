local M = {}

M.config = {
  keymaps = {
    search = "<leader>mp",
    browse = "<leader>mb",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  if M.config.keymaps.search then
    vim.keymap.set("n", M.config.keymaps.search, function()
      require("man-pages.telescope").search_man_page()
    end, { desc = "Search man pages" })
  end
  
  if M.config.keymaps.browse then
    vim.keymap.set("n", M.config.keymaps.browse, function()
      require("man-pages.telescope").man_pages()
    end, { desc = "Browse all man pages" })
  end
  
  vim.api.nvim_create_user_command("ManSearch", function(args)
    if args.args and args.args ~= "" then
      local utils = require("man-pages.utils")
      local content = utils.get_man_page(args.args)
      if content then
        vim.cmd("Man " .. args.args)
      else
        require("man-pages.telescope").search_man_page()
      end
    else
      require("man-pages.telescope").search_man_page()
    end
  end, { nargs = "?", desc = "Search for man pages" })
  
  vim.api.nvim_create_user_command("ManBrowse", function()
    require("man-pages.telescope").man_pages()
  end, { desc = "Browse all available man pages" })
end

return M