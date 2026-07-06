vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "Fastfile",
    "Appfile",
    "Deliverfile",
    "Scanfile",
    "Matchfile",
    "Gymfile",
    "Snapshotfile",
    "Screengrabfile",
  },
  callback = function() vim.bo.filetype = "ruby" end,
})
