{ config, pkgs, ... }:

{
  home.file.".config/mako/config".source = ./dotfiles/mako/config;
}
