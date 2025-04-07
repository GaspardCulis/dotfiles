{
  config,
  _inputs,
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
      ".config/zellij/config.kdl".source = ../../../config/zellij/config.kdl;
    };

    home.packages = [
      pkgs.zellij
    ];
  };
}
