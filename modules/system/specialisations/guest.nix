{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.specialisations.guest;
in {
  options.gasdev.specialisations.guest = {
    enable = mkEnableOption "Enable Guest specialisation";
    user = mkOption {
      type = types.nonEmptyStr;
      description = "User for guest session";
      default = "guest";
    };
  };

  config = mkIf cfg.enable {
    specialisation.guest.configuration = {
      system.nixos.tags = ["Guest"];

      services = {
        desktopManager.plasma6.enable = true;
        displayManager.sddm.enable = true;
        displayManager.sddm.wayland.enable = true;

        displayManager.autoLogin.enable = true;
        displayManager.autoLogin.user = "${cfg.user}";
      };

      users.groups."${cfg.user}".name = "${cfg.user}";
      users.users."${cfg.user}" = {
        isNormalUser = true;
        extraGroups = [
          "video"
          "seat"
          "audio"
          "networkmanager"
        ];
        group = "${cfg.user}";

        packages = with pkgs; [
          firefox
          gimp
          libreoffice-fresh
        ];
      };

      fileSystems."/home/${cfg.user}" = {
        device = "none";
        fsType = "tmpfs"; # Can be stored on normal drive or on tmpfs as well
        options = ["size=4G" "mode=777"];
      };
    };
  };
}
