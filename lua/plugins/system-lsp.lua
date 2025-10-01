-- Use Nix (system) managed language servers & formatters instead of Mason binaries
-- Rationale: Mason downloads generic glibc-linked executables that fail on NixOS
-- ("Could not start dynamically linked executable"). Using Nix packages avoids
-- runtime loader issues and is fully reproducible.
--
-- Add the following (example) packages to your Nix / Home Manager config:
--   home.packages = with pkgs; [
--     lua-language-server
--     marksman
--     stylua
--     nixd  -- already handled in nixd.lua
--   ];

-- This module:
--  * Ensures Mason does not try to (re)install lua-language-server, marksman, stylua, nixd...
--  * Configures lspconfig to use system executables (mason = false)
--  * Points conform.nvim (LazyVim's formatter) at system stylua
--
-- If you later really want Mason for something, just remove that entry from the blacklist.

local blacklist = {
  ["lua-language-server"] = true,
  marksman = true,
  stylua = true,
  nil_ls = true, -- we disable it in favor of nixd
  nixd = true,   
}

return {
  -- Prune generic mason package installs (formatters, linters, etc.)
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      if opts.ensure_installed then
        for i = #opts.ensure_installed, 1, -1 do
          if blacklist[opts.ensure_installed[i]] then
            table.remove(opts.ensure_installed, i)
          end
        end
      end
    end,
  },

  -- LSP servers: disable mason integration & rely on PATH (Nix profile)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- disable nil_ls so it never attaches (prefer nixd)
        nil_ls = { enabled = false },
        -- rely on system nixd (installed via Nix profile / flake)
        nixd = { mason = false },
        lua_ls = {
          mason = false,
          -- System binary name. If you put a wrapper in ~/.local/bin you can point to it.
          cmd = { "lua-language-server" },
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        marksman = {
          mason = false,
          -- marksman uses a subcommand 'server' for LSP mode
          cmd = { "marksman", "server" },
        },
        -- stylua is a formatter only; listed here only if some plugin queries server table.
      },
    },
  },

  -- Formatter (LazyVim default uses conform.nvim). Point to system stylua.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Guarantee lua formatting uses stylua (system)
      local lua = opts.formatters_by_ft.lua or { "stylua" }
      if type(lua) == "table" then
        -- ensure stylua present once
        local has = false
        for _, v in ipairs(lua) do if v == "stylua" then has = true break end end
        if not has then table.insert(lua, 1, "stylua") end
      end
      opts.formatters_by_ft.lua = lua

      opts.formatters = opts.formatters or {}
      opts.formatters.stylua = vim.tbl_deep_extend("force", opts.formatters.stylua or {}, {
        command = "stylua", -- rely on PATH
      })
      return opts
    end,
  },
}
