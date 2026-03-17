{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.ashell;
in {
  options.gasdev.desktop.ashell = {
    enable = mkEnableOption "Enable opiniated service config";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ashell;
    };
    scale = lib.mkOption {
      description = "The scaling factor of the status bar";
      type = lib.types.float;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      systemd.enable = true;
      package = cfg.package;

      settings = {
        log_level = "warn";
        outputs = "All";
        position = "Top";
        layer = "Top";

        modules = {
          left = ["Clock" "Workspaces" "MediaPlayer"];
          center = ["WindowTitle"];
          right = ["SystemInfo" "Settings" "Tray"];
        };

        workspaces.enable_workspace_filling = true;
        media_player.max_title_length = 50;

        settings = {
          audio_sinks_more_cmd = "pavucontrol -t 3";
          audio_sources_more_cmd = "pavucontrol -t 4";
          wifi_more_cmd = "nm-connection-editor";
          vpn_more_cmd = "nm-connection-editor";
          bluetooth_more_cmd = "blueman-manager";
        };

        appearance = {
          style = "Islands";
          scale_factor = cfg.scale;

          # Let stylix handle the rest
        };
      };
    };

    home.packages = with pkgs; [
      # Script dependencies
      blueman
      pavucontrol
      networkmanagerapplet
    ];
  };
}
