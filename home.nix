{ config, pkgs, ... }:

{
  imports = [
    ./home/kitty.nix
    ./home/fastfetch.nix
    ./home/waybar.nix
    ./home/wofi.nix
    ./home/mako.nix
  ];

  home.username = "nick";
  home.homeDirectory = "/home/nick";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    btop
    tree
    unzip
  ];

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      # Show fastfetch on interactive Kitty startup
      if [[ $- == *i* ]] && [[ "$TERM" == "xterm-kitty" ]] && command -v fastfetch >/dev/null 2>&1; then
          fastfetch
      fi
    '';
  };
}
