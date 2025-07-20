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
      kdePackages.discover
    ];

    home.file.".profile".text = ''
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
    '';

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
