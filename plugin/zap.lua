-- Register *.zap detection as soon as the plugin is on the runtimepath, so the
-- filetype is correct even before (or without) require("zap").setup().
if vim.g.loaded_zap then
    return
end
vim.g.loaded_zap = true

vim.filetype.add({ extension = { zap = "zap" } })
