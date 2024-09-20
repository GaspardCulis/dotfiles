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
}
