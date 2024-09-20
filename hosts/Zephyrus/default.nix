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

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  console.keyMap = "fr";

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # User config
  users.groups.gaspard = {
    name = "gaspard";
  };
  users.users.gaspard = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
    ];
    group = "gaspard";
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "gaspard" = import ../../users/gaspard.nix;
    };
  };

  # Programs
  environment.systemPackages = [pkgs.git];

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

  system.stateVersion = "24.11";
}
