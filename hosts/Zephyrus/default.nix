{
  inputs,
  pkgs,
  lib,
  config,
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

  # Network & Bluetooth
  networking.wireless.iwd.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Audio
  hardware.pulseaudio.enable = true;

  # Services
  services.seatd.enable = true;
  services.blueman.enable = true;
  services.pipewire.pulse.enable = true;
  services.power-profiles-daemon.enable = true;

  # Programs
  environment.systemPackages = [
    pkgs.git
    pkgs.ncdu
    pkgs.neofetch
    pkgs.bottom
    pkgs.htop
    pkgs.iwgtk
  ];

  # NVIDIA
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["nvidia-x11" "nvidia-settings"];

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;

    open = false; # Bruuh

    prime = {
      amdgpuBusId = "PCI:7:0:0";
      nvidiaBusId = "PCI:1:0:0";
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