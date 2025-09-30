-- Custom notification settings: increase popup visibility duration
-- Typical ranges: 3000 (3s), set to 0 to make them stay until manually dismissed.
return {
  {
    "folke/noice.nvim",
    -- optional = true, -- in case it's disabled upstream
    opts = function(_, opts)
      opts = opts or {}
      opts.views = opts.views or {}
      -- The "notify" view is what wraps nvim-notify
      opts.views.notify = vim.tbl_deep_extend("force", opts.views.notify or {}, {
        timeout = 6000,  -- match notify timeout (ms)
        replace = false, -- don't replace existing notifications instantly
      })
      return opts
    end,
  },
}
