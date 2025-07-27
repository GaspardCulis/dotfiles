{
  inputs,
  config,
  _pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.users;
in {
  options.gasdev.users = {
    gaspard = {
      enable = mkEnableOption "Enable user";
      enableDesktop = mkEnableOption "Enable desktop environment";
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
          if cfg.gaspard.enableDesktop
          then ["video" "seat"]
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
        "gaspard" = mkIf cfg.gaspard.enable {
          home.username = "gaspard";
          home.homeDirectory = "/home/gaspard";
          home.stateVersion = "24.05";

          programs.home-manager.enable = true;
          programs.direnv.enable = true;

          gasdev = {
            shell = {
              bash.enable = true;
              helix.enable = true;
              zellij.enable = true;
            };
            desktop = mkIf cfg.gaspard.enableDesktop {
              enable = true;
              niri = {
                enable = true;
                autoStart = true;
              };
              apps = mkIf cfg.gaspard.enableDesktop {
                firefox = {
                  progressiveWebApps.enable = true;
                  profiles.gaspard.enable = true;
                };
              };
              udiskr.enable = true;
            };
          };

          services = {
            ssh-agent.enable = true;
          };

          xdg.mimeApps = mkIf cfg.gaspard.enableDesktop {
            enable = true;
            defaultApplications = {
              "text/html" = "firefox.desktop";
              "x-scheme-handler/http" = "firefox.desktop";
              "x-scheme-handler/https" = "firefox.desktop";
              "x-scheme-handler/about" = "firefox.desktop";
              "x-scheme-handler/unknown" = "firefox.desktop";
            };
          };
        };
      };
    };
  };
}
