{ config, pkgs, ... }:

{
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
}
