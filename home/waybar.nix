{ config, pkgs, ... }:

{
  home.file.".config/waybar/config".source = ./dotfiles/waybar/config;
  home.file.".config/waybar/style.css".source = ./dotfiles/waybar/style.css;
}
