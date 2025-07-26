{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.specialisations.steamos;
in {
  options.gasdev.specialisations.steamos = {
    enable = mkEnableOption "Enable SteamOS specialisation";
    user = mkOption {
      type = types.nonEmptyStr;
      description = "User for SteamOS session";
      default = "steam";
    };
  };

  config = mkIf cfg.enable {
    specialisation.steam.configuration = {
      system.nixos.tags = ["SteamOS"];

      users.groups."${cfg.user}".name = "${cfg.user}";
      users.users."${cfg.user}" = {
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "video"
          "seat"
          "audio"
          "gamemode"
          "networkmanager"
        ];
        group = "${cfg.user}";
      };

      home-manager.users."${cfg.user}" = {
        home.username = "${cfg.user}";
        home.homeDirectory = "/home/${cfg.user}";
        home.stateVersion = "24.05";

        gasdev.desktop.apps = {
          firefox = {
            enable = true;
            progressiveWebApps.enable = true;
          };
          software-center.enable = true;
        };
      };

      services.desktopManager.plasma6.enable = true;

      jovian = {
        steam = {
          enable = true;
          autoStart = true;
          user = "${cfg.user}";
          desktopSession = "plasma";
        };
        steamos = {
          enableSysctlConfig = true;
          enableDefaultCmdlineConfig = true;
        };
      };

      virtualisation.waydroid.enable = true;

      environment.systemPackages = with pkgs; [
        mangohud
        appimage-run
        # Games
        # inputs.suyu.packages.${pkgs.system}.suyu
        rpcs3
        prismlauncher
        vintagestory
      ];

      environment.sessionVariables = {
        XKB_DEFAULT_LAYOUT = "fr";
      };
      # Gaming optimizations
      boot = {
        kernelParams = [
          "clocksource=tsc"
          "tsc=reliable"
        ];
      };
    };
  };
}
