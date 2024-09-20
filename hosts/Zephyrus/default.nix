{
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
}
