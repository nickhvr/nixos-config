{ config, pkgs, ... }:

{
  home.file.".config/hypr/scripts/wallpaper-picker.sh" = {
    source = ./dotfiles/hypr/scripts/wallpaper-picker.sh;
    executable = true;
  };
}
