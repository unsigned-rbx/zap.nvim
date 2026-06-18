-- zap.nvim — Zap (Roblox networking DSL) support for Neovim.
--
-- Provides:
--   * `*.zap` filetype detection
--   * LSP (completion, diagnostics, hover, definition, references, rename, format)
--     via the standalone zap-language-server
--   * tree-sitter highlighting/folds via the filiptibell/tree-sitter-zap grammar
--
-- Usage:  require("zap").setup({ capabilities = <your lsp capabilities> })

local M = {}

local defaults = {
    lsp = true, -- enable the language server
    highlight = true, -- tree-sitter highlighting (compiles grammar on first .zap open)
    server_cmd = nil, -- override the server command; nil = auto-resolve
    capabilities = nil, -- LSP client capabilities (nil = auto-detect blink/cmp)
    root_markers = { ".git" },
}

-- Auto-detect completion capabilities when the caller didn't pass any.
local function resolve_capabilities(caps)
    if caps then
        return caps
    end
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        return blink.get_lsp_capabilities()
    end
    local ok2, cmp = pcall(require, "cmp_nvim_lsp")
    if ok2 then
        return cmp.default_capabilities()
    end
    return nil -- vim.lsp uses its defaults
end

--- @param user? table
function M.setup(user)
    local opts = vim.tbl_deep_extend("force", defaults, user or {})

    vim.filetype.add({ extension = { zap = "zap" } })

    if opts.highlight then
        require("zap.treesitter").setup()
    end
    if opts.lsp then
        require("zap.lsp").setup({
            cmd = opts.server_cmd,
            capabilities = resolve_capabilities(opts.capabilities),
            root_markers = opts.root_markers,
        })
    end
end

return M
