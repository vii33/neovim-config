# AI Assistant Project Instructions

Purpose: Help AI agents quickly understand and extend this Neovim configuration (a thin customization layer on top of LazyVim + lazy.nvim).

# Environment
- Neovim runs under NixOS (https://nixos.org/) with a custom user profile.
- The NixOS config is in a separate repo: `/home/vii/nixos-config`. Use this to check for further needed dependencies.
  - The neovim config sits in `modules/home/neovim.nix`
- The general structure is a for of LazyVim (https://www.lazyvim.org/)
