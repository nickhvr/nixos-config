{ config, pkgs, ... }:

{
  home.file.".config/wofi/config".source = ./dotfiles/wofi/config;
  home.file.".config/wofi/style.css".source = ./dotfiles/wofi/style.css;
  home.file.".config/wofi/power.css".source = ./dotfiles/wofi/power.css;
}
