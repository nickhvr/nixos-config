{ config, pkgs, ... }:

{
  home.file.".config/hypr/scripts/wallpaper-picker.sh" = {
    source = ./dotfiles/hypr/scripts/wallpaper-picker.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/apply-wal-theme.sh" = {
    source = ./dotfiles/hypr/scripts/apply-wal-theme.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/powermenu.sh" = {
    source = ./dotfiles/hypr/scripts/powermenu.sh;
    executable = true;
  };
}
