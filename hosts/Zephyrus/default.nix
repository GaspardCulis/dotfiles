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

  security.pam.services.swaylock = {};

  # Services
  services.seatd.enable = true;
  services.blueman.enable = true;
  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = true;
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  systemd.services.ollama = {
    wantedBy = pkgs.lib.mkForce [];
  };

  # Programs
  environment.systemPackages = with pkgs; [
    git
    wget
    ncdu
    neofetch
    bottom
    htop
    wg-netmanager
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

  system.stateVersion = "24.11";
}
