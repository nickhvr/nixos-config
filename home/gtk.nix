{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Noto Sans";
      size = 10;
    };

    gtk3.extraCss = ''
      @import url("file:///home/nick/.cache/wal/gtk.css");
    '';

    gtk4.extraCss = ''
      @import url("file:///home/nick/.cache/wal/gtk.css");
    '';
  };
}
