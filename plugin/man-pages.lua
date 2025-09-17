if vim.fn.has("nvim-0.7") ~= 1 then
  vim.notify("man-pages.nvim requires Neovim 0.7+", vim.log.levels.ERROR)
  return
end

if vim.g.loaded_man_pages then
  return
end

vim.g.loaded_man_pages = true