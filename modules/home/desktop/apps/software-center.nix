{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.software-center;
in {
  options.gasdev.desktop.apps.software-center = {
    enable = mkEnableOption "Enable module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      flatpak
      gnome-software
    ];

    xdg.systemDirs.data = [
      "$HOME/.local/share/flatpak/exports/share"
    ];

    systemd.user.services.flatpak-repo = {
      Unit = {
        Description = "Automatic Flatpak repo configuration";
        After = ["network.target"];
      };

      Service = {
        ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
        Restart = "on-failure";
        RestartSec = "20s";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
