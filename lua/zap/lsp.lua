-- Language server wiring for Zap. Reuses the standalone `zap-language-server`
-- binary (https://github.com/filiptibell/zap-language-server) over LSP.

local M = {}

-- Prefer a server on PATH (e.g. `rokit add filiptibell/zap-language-server`);
-- otherwise fall back to the binary bundled in the installed VSCode extension.
local function default_cmd()
    if vim.fn.executable("zap-language-server") == 1 then
        return { "zap-language-server", "serve" }
    end
    local hits = vim.fn.glob(
        vim.fn.expand("~/.vscode/extensions/filiptibell.zap-language-server-*/binaries/*/zap-language-server"),
        true,
        true
    )
    if hits[1] then
        return { hits[1], "serve" }
    end
end

--- @param opts? { cmd?: string[], capabilities?: table, root_markers?: string[] }
--- @return boolean enabled
function M.setup(opts)
    opts = opts or {}
    local cmd = opts.cmd or default_cmd()
    if not cmd then
        -- No server found; highlighting still works. Stay quiet (highlight-only is valid).
        return false
    end

    vim.lsp.config("zap", {
        cmd = cmd,
        filetypes = { "zap" },
        root_markers = opts.root_markers or { ".git" },
        capabilities = opts.capabilities,
    })
    vim.lsp.enable("zap")
    return true
end

return M
