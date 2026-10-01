{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./steam-gaming.nix
  ];

  hardware.asahi.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # XBox wireless support
  hardware.xpadneo.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.systemd.enable = true;
  boot.loader.timeout = 2;
  boot.tmp.useTmpfs = true;

  networking.hostName = "Hermes";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  time.timeZone = pkgs.lib.mkForce "Australia/Adelaide";

  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["fr_FR.UTF-8/UTF-8"];
  };

  gasdev = {
    users.gaspard = {
      enable = true;
      desktop.enable = true;
      extraGroups = [
        "uucp"
        "audio"
        "dialout"
        "adbusers"
        "networkmanager"
      ];

      extraModules = [
        {
          gasdev = {
            shell.helix.lspProfile = "bloated";
            shell.helix.wakatime = true;
            desktop.noctalia.scale = 1.2;
          };
        }
      ];
    };
  };

  users.users.emma = {
    isNormalUser = true;
    group = "users";
    extraGroups = [
      "uucp"
      "audio"
      "dialout"
      "networkmanager"
    ];
  };
  home-manager.users."emma" = {
    imports = [
      ../../../modules/home/desktop/apps/software-center.nix
    ];

    gasdev.desktop.apps.software-center.enable = true;

    gtk.gtk2.configLocation = "/home/emma/.config/.gtkrc-2.0";

    home.username = "emma";
    home.homeDirectory = "/home/emma";
    home.stateVersion = "26.05";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    usbutils
    cachix
    helix
    wget

    wg-netmanager
  ];

  # Programs
  programs = {
    niri.enable = true;
  };
  # Localsend currently broken fonts, see https://github.com/localsend/localsend/issues/2873
  # programs.localsend = {
  #   enable = true;
  #   openFirewall = true;
  # };
  networking.firewall.allowedTCPPorts = [53317];
  networking.firewall.allowedUDPPorts = [53317];

  # Services
  services = {
    accounts-daemon.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;

    flatpak.enable = true;

    udisks2.enable = true;
    gvfs.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  # Fixes
  # Unlock KDE wallet using LUKS
  systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
  security.pam.services.plasmalogin-autologin.rules.auth = {
    systemd_loadkey = {
      order = 0;
      control = "optional";
      modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
    };
    plasmalogin = {
      order = 1;
      control = "include";
      modulePath = "plasmalogin";
    };
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
  ];
  # wireplumber shutdown hang
  systemd.user.services.wireplumber.serviceConfig.TimeoutStopSec = 3;

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
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
