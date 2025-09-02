{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gasdev.users;
in {
  options.gasdev.users = {
    gaspard = {
      enable = mkEnableOption "Enable user";
      desktop = {
        enable = mkEnableOption "Enable desktop environment";
        enableGaming = mkEnableOption "Enable default games config";
      };
      extraGroups = mkOption {
        type = lib.types.listOf lib.types.nonEmptyStr;
        description = "Extra user groups";
        default = [];
      };
    };
  };

  config = {
    users.groups.gaspard = mkIf cfg.gaspard.enable {
      name = "gaspard";
    };
    users.users.gaspard = mkIf cfg.gaspard.enable {
      isNormalUser = true;
      extraGroups =
        [
          "wheel"
        ]
        ++ (
          if cfg.gaspard.desktop.enable
          then ["video" "seat"]
          else []
        )
        ++ (
          if cfg.gaspard.desktop.enableGaming
          then ["gamemode"]
          else []
        )
        ++ cfg.gaspard.extraGroups;
      group = "gaspard";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICm9trfkWL5FVHuo/5YONd+oZY4nQnpHLDOnXoOrl9j9 u0_a220@pixel"
      ];
    };

    nix.settings.trusted-users = mkIf cfg.gaspard.enable ["gaspard"];

    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      sharedModules = [
        ../home
      ];
      users = {
        "gaspard" = mkIf cfg.gaspard.enable (import ../../users/gaspard.nix {
          inherit pkgs;
          enableDesktop = cfg.gaspard.desktop.enable;
          enableGaming = cfg.gaspard.desktop.enableGaming;
        });
      };
    };
  };
}
