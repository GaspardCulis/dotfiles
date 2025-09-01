{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.shell.zellij;
in {
  options.gasdev.shell.zellij = {
    enable = mkEnableOption "Enable opiniated zellijconfig";
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/zellij".source = ../../../config/zellij;
    };

    home.packages = [
      pkgs.zellij
    ];
  };
}
