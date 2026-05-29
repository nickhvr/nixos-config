{ config, pkgs, ... }:

{

  home.file.".config/hypr/scripts/lid-lock.sh" = {
    source = ./dotfiles/hypr/scripts/lid-lock.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/wallpaper-picker.sh" = {
    source = ./dotfiles/hypr/scripts/wallpaper-picker.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/quickapps.sh" = {
    source = ./dotfiles/hypr/scripts/quickapps.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/wallpaper-picker-waybar.sh" = {
    source = ./dotfiles/hypr/scripts/wallpaper-picker-waybar.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/apply-wal-theme.sh" = {
    source = ./dotfiles/hypr/scripts/apply-wal-theme.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/restore-wallpaper-theme.sh" = {
    source = ./dotfiles/hypr/scripts/restore-wallpaper-theme.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/powermenu.sh" = {
    source = ./dotfiles/hypr/scripts/powermenu.sh;
    executable = true;
  };

  home.file.".config/hypr/scripts/screenshot-area.sh" = {
    source = ./dotfiles/hypr/scripts/screenshot-area.sh;
    executable = true;
  };
}
