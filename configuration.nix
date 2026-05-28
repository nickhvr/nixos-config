{ config, pkgs, ... }:

let
  nix-search-script = pkgs.writeShellScriptBin "ns" ''
    export PATH=${pkgs.lib.makeBinPath [
      pkgs.fzf
      pkgs.nix-search-tv
    ]}:$PATH

    ${builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh"}
  '';
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # -------------------------
  # Nix
  # -------------------------
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";

  # -------------------------
  # Bootloader
  # -------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -------------------------
  # Networking
  # -------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # -------------------------
  # Locale / Time / Keyboard
  # -------------------------
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # -------------------------
  # User
  # -------------------------
  users.users.nick = {
    isNormalUser = true;
    description = "Nick Haverkamp";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = true;

  # -------------------------
  # Fonts
  # -------------------------
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  # -------------------------
  # Display Server / Hyprland
  # -------------------------
  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sessionPackages = [
    pkgs.hyprland
  ];

  services.displayManager.defaultSession = "hyprland";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha-mauve";

    extraPackages = with pkgs; [
      qt6.qt5compat
      kdePackages.qtsvg
      kdePackages.qtmultimedia
    ];
  };

  # -------------------------
  # Wayland Portals
  # -------------------------
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # -------------------------
  # Audio
  # -------------------------
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # -------------------------
  # Programs
  # -------------------------
  programs.git.enable = true;

  # -------------------------
  # System Packages
  # -------------------------
  environment.systemPackages = with pkgs; [
    # Hyprland / Desktop
    hyprland
    hyprpaper
    hyprlock
    waybar
    wofi
    rofi
    mako

    # Terminal / Browser / File Manager
    kitty
    firefox
    xfce.thunar

    # Screenshots / Clipboard / Media
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    pavucontrol
    brightnessctl
    playerctl
    networkmanagerapplet

    # Themes / Appearance
    bibata-cursors
    papirus-icon-theme
    gnome-themes-extra
    adw-gtk3
    lxappearance

    # CLI / Development
    git
    wget
    curl
    fastfetch
    pywal
    neovim
    unzip
    python313
    codex
    nix-search-script
    libnotify
    file
    lazygit

    #Programs
    vscode
    teams-for-linux

    # SDDM Theme
    (catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "Noto Sans";
      fontSize = "10";
      background = "${./assets/space-pixel.png}";
      loginBackground = true;
    })
  ];
}
