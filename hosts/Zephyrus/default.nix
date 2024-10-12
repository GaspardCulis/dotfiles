{
  inputs,
  pkgs,
  lib,
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
  services.power-profiles-daemon.enable = true;

  # Programs
  environment.systemPackages = with pkgs; [
    git
    wget
    ncdu
    neofetch
    bottom
    htop
    iwgtk
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
