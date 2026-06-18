# zap.nvim

Neovim support for [Zap](https://zap.redblox.dev/), the Roblox networking DSL.

It wires up the existing upstream tooling rather than reimplementing anything:

- **Language server** — completion, diagnostics, hover, go-to-definition,
  references, rename, and formatting via
  [`zap-language-server`](https://github.com/filiptibell/zap-language-server).
- **Syntax highlighting & folds** — the
  [`tree-sitter-zap`](https://github.com/filiptibell/tree-sitter-zap) grammar,
  compiled locally and run through Neovim's built-in tree-sitter.
- **Filetype** — `*.zap`, `--` comments, bracket pairs.

## Requirements

- Neovim 0.11+ (uses `vim.lsp.config` / `vim.lsp.enable`).
- `cc` and `curl` — used once to fetch and compile the tree-sitter grammar.
- The `zap-language-server` binary for LSP features. Install it with
  [Rokit](https://github.com/rokit-rs/rokit):

  ```sh
  rokit add filiptibell/zap-language-server
  ```

  If it isn't on `PATH`, the plugin falls back to the binary bundled inside the
  installed VSCode "Zap Language Server" extension, when present.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "unsigned-rbx/zap.nvim",
  lazy = false, -- required: see note below
  opts = {},
}
```

`opts = {}` is all you need — lazy.nvim calls `require("zap").setup({})` for you,
and the language-server capabilities auto-detect `blink.cmp` / `cmp_nvim_lsp`.
For highlighting only (no language server), use `opts = { lsp = false }`.

> **Why `lazy = false`?** `*.zap` is a brand-new filetype, so `ft = "zap"`
> lazy-loading can't trigger on its own — nothing detects a `.zap` file until the
> plugin has loaded. Loading at startup is cheap: it only registers the filetype
> and a couple of autocmds; the grammar compile and the language-server start stay
> deferred until you actually open a `.zap` file. If you'd rather lazy-load,
> register the filetype yourself so the trigger exists:
>
> ```lua
> {
>   "unsigned-rbx/zap.nvim",
>   ft = "zap",
>   init = function()
>     vim.filetype.add({ extension = { zap = "zap" } })
>   end,
>   opts = {},
> }
> ```

## Configuration

`setup()` accepts:

| Option         | Default       | Description                                                        |
| -------------- | ------------- | ----------------------------------------------------------------- |
| `lsp`          | `true`        | Enable the language server.                                       |
| `highlight`    | `true`        | Enable tree-sitter highlighting (compiles the grammar on demand). |
| `server_cmd`   | auto          | Override the server command, e.g. `{ "zap-language-server", "serve" }`. |
| `capabilities` | auto          | LSP client capabilities. Auto-detects `blink.cmp` / `cmp_nvim_lsp`. |
| `root_markers` | `{ ".git" }`  | Markers used to resolve the workspace root.                       |

Example pairing the completion capabilities with [blink.cmp](https://github.com/saghen/blink.cmp):

```lua
{
  "unsigned-rbx/zap.nvim",
  lazy = false,
  dependencies = { "saghen/blink.cmp" },
  config = function()
    require("zap").setup({
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })
  end,
}
```

## Commands

- `:ZapInstallGrammar` — (re)download and compile the tree-sitter grammar
  (e.g. after a Neovim tree-sitter ABI bump). The compiled parser lives in
  `stdpath("data")/site/parser/zap.so`.

## Credits

All the heavy lifting is upstream work by [Filip Tibell](https://github.com/filiptibell):
the language server and the tree-sitter grammar (both MIT licensed). This plugin
just connects them to Neovim. The grammar's parser and queries are downloaded
from `tree-sitter-zap` at install time.
