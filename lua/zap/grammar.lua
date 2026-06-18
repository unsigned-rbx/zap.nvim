-- Manages the Zap tree-sitter grammar.
--
-- Zap isn't in nvim-treesitter's registry, so we drive Neovim's *core* tree-sitter
-- directly: download the MIT-licensed filiptibell/tree-sitter-zap sources + queries,
-- compile a parser into the site dir, and let `vim.treesitter` pick it up. Builds
-- once, then cached.

local M = {}

local REPO = "https://raw.githubusercontent.com/filiptibell/tree-sitter-zap/main"

local function site()
    return vim.fn.stdpath("data") .. "/site"
end

local function parser_path()
    return site() .. "/parser/zap.so"
end

--- @return boolean
function M.installed()
    return vim.uv.fs_stat(parser_path()) ~= nil
end

--- Download + compile the grammar and install its queries. Async.
--- @param opts? { on_done?: fun(ok: boolean) }
function M.install(opts)
    opts = opts or {}
    local on_done = opts.on_done or function() end

    if vim.fn.executable("cc") ~= 1 then
        vim.notify("zap.nvim: no C compiler (cc) found on PATH", vim.log.levels.ERROR)
        return on_done(false)
    end
    if vim.fn.executable("curl") ~= 1 then
        vim.notify("zap.nvim: curl not found on PATH", vim.log.levels.ERROR)
        return on_done(false)
    end

    local parser_dir = site() .. "/parser"
    local query_dir = site() .. "/queries/zap"

    -- One shell pass: fetch sources + queries, compile to parser/zap.so. Paths
    -- under stdpath("data") contain no spaces, so plain quoting is safe.
    local script = table.concat({
        "set -e",
        "TMP=$(mktemp -d)",
        ('mkdir -p "$TMP/src/tree_sitter" "%s" "%s"'):format(parser_dir, query_dir),
        ('curl -fsSL "%s/src/parser.c" -o "$TMP/src/parser.c"'):format(REPO),
        ('curl -fsSL "%s/src/tree_sitter/parser.h" -o "$TMP/src/tree_sitter/parser.h"'):format(REPO),
        ('cc -o "%s/zap.so" -shared -fPIC -Os -I"$TMP/src" "$TMP/src/parser.c"'):format(parser_dir),
        ('for q in highlights indents folds; do curl -fsSL "%s/queries/$q.scm" -o "%s/$q.scm"; done'):format(
            REPO,
            query_dir
        ),
        'rm -rf "$TMP"',
    }, "\n")

    vim.notify("zap.nvim: building tree-sitter grammar…", vim.log.levels.INFO)
    vim.system({ "sh", "-c", script }, { text = true }, vim.schedule_wrap(function(out)
        if out.code ~= 0 then
            vim.notify("zap.nvim: grammar build failed\n" .. (out.stderr or ""), vim.log.levels.ERROR)
            return on_done(false)
        end
        pcall(vim.treesitter.language.add, "zap") -- register now that parser exists
        vim.notify("zap.nvim: grammar installed", vim.log.levels.INFO)
        on_done(true)
    end))
end

--- Make the grammar usable, building it on first call. `cb(ok)` runs when ready.
--- @param cb? fun(ok: boolean)
function M.ensure(cb)
    cb = cb or function() end
    if M.installed() then
        local ok = pcall(vim.treesitter.language.add, "zap")
        return cb(ok)
    end
    M.install({ on_done = cb })
end

return M
