{
  config,
  flake,
  lib,
  ...
}:
with lib; let
  inherit (flake.inputs) self;
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
    };

    nix.settings.trusted-users = ["gaspard"];

    home-manager.users."gaspard" = mkIf cfg.enable {
      imports =
        if cfg.desktop.enable
        then [(self + /configurations/home/gaspard)]
        else [(self + /configurations/home/gaspard/desktop.nix)];
    };
  };
}
