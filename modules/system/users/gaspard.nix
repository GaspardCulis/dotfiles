{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.users.gaspard;
in {
  options.gasdev.users.gaspard = {
    enable = mkEnableOption "Enable user";
    desktop = {
      enable = mkEnableOption "Enable desktop environment";
    };
    extraGroups = mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      description = "Extra user groups";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    users.groups.gaspard = {
      name = "gaspard";
    };
    users.users.gaspard = {
      isNormalUser = true;
      extraGroups =
        [
          "wheel"
        ]
        ++ (
          if cfg.desktop.enable
          then ["video" "seat"]
          else []
        )
        ++ cfg.extraGroups;
      group = "gaspard";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICm9trfkWL5FVHuo/5YONd+oZY4nQnpHLDOnXoOrl9j9 u0_a220@pixel"
      ];
    };

    nix.settings.trusted-users = ["gaspard"];

    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      sharedModules = [
        ../home
      ];
      users = {
        "gaspard" = import ../../../users/gaspard.nix {
          inherit pkgs;
          enableDesktop = cfg.desktop.enable;
        };
      };
    };
  };
}
