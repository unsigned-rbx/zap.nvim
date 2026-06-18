-- Tree-sitter highlighting for Zap, via Neovim's core tree-sitter + the
-- grammar managed in zap.grammar.

local grammar = require("zap.grammar")

local M = {}

local function start(buf)
    grammar.ensure(function(ok)
        if ok and vim.api.nvim_buf_is_valid(buf) then
            vim.treesitter.start(buf, "zap")
        end
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("zap.treesitter", { clear = true })

    -- Highlight zap buffers as they open (grammar builds lazily on first use).
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "zap",
        callback = function(args)
            start(args.buf)
        end,
    })

    -- Catch any zap buffers already open when setup ran (e.g. `nvim foo.zap`).
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == "zap" then
            start(b)
        end
    end

    vim.api.nvim_create_user_command("ZapInstallGrammar", function()
        grammar.install({
            on_done = function(ok)
                if not ok then
                    return
                end
                for _, b in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[b].filetype == "zap" then
                        vim.treesitter.start(b, "zap")
                    end
                end
            end,
        })
    end, { desc = "Download & (re)compile the Zap tree-sitter grammar" })
end

return M
