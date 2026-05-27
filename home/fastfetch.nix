{ config, pkgs, ... }:

{
  home.file.".config/fastfetch/config.jsonc".source = ./dotfiles/fastfetch/config.jsonc;
}
