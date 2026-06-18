-- Zap uses `--` line comments. Formatting is handled by the language server.
vim.bo.commentstring = "-- %s"
vim.bo.comments = ":--"

-- The grammar ships folds.scm; make folds available without auto-collapsing.
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldenable = false
