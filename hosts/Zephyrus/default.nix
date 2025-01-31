{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";

  security.pam.services.swaylock = {};

  # Services
  services.seatd.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.power-profiles-daemon.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false; # Faster boot time

  # Programs
  environment.systemPackages = with pkgs; [
    git
    wget
    ncdu
    neofetch
    bottom
    htop
    unzip
    wg-netmanager
    networkmanager-openconnect
    podman-compose
  ];

  #Podman
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # ADB
  programs.adb.enable = true;

  # Gaming
  programs.gamemode.enable = true;

  # Other
  programs.nix-ld.enable = true;
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # User config
  users.groups.gaspard = {
    name = "gaspard";
  };
  users.users.gaspard = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "seat"
      "audio"
      "adbusers"
      "gamemode"
      "networkmanager"
    ];
    group = "gaspard";
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "gaspard" = import ../../users/gaspard.nix;
    };
  };

  # Steam specialisation
  specialisation.steam.configuration = {
    system.nixos.tags = ["steam"];

    users.groups.steam.name = "steam";
    users.users.steam = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [
        "video"
        "seat"
        "audio"
        "gamemode"
        "networkmanager"
      ];
      group = "steam";
    };

    services.desktopManager.plasma6.enable = true;
    services.flatpak.enable = true;

    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = "steam";
        desktopSession = "plasma";
      };
      steamos = {
        enableSysctlConfig = true;
        enableDefaultCmdlineConfig = true;
      };
    };

    programs.firefox = {
      enable = true;
      nativeMessagingHosts.packages = [pkgs.firefoxpwa];
    };

    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      firefoxpwa
      appimage-run
      # Games
      suyu
      rpcs3
      prismlauncher
      vintagestory
    ];

    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "fr";
    };
    # Gaming optimizations
    boot = {
      kernelParams = [
        "clocksource=tsc"
        "tsc=reliable"
      ];
    };
  };

  system.stateVersion = "24.11";
}
