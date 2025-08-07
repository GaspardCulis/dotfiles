{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";

  security.pam.services.swaylock = {};

  gasdev = {
    podman.enable = true;
    openssh = {
      enable = true;
      openFirewall = true;
    };
    users.gaspard = {
      enable = true;
      enableDesktop = true;
      extraGroups = [
        "uucp"
        "audio"
        "dialout"
        "adbusers"
        "gamemode"
        "networkmanager"
      ];
    };
    # specialisations.steamos.enable = true;
    specialisations.guest.enable = true;
  };

  # Services
  services.seatd.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.asusd.enable = true;
  services.power-profiles-daemon.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false; # Faster boot time

  # Programs
  environment.systemPackages = with pkgs; [
    cachix
    wg-netmanager
    networkmanager-openconnect
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
    fonts = {
      sizes.terminal = 10;

      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  programs = {
    niri.enable = true;
    nix-ld.enable = true;
    adb.enable = true;
    gamemode.enable = true;

    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  system.stateVersion = "24.11";
}
