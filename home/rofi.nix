{ config, pkgs, ... }:

{
  home.file.".config/rofi/wallpaper.rasi".source = ./dotfiles/rofi/wallpaper.rasi;
}
