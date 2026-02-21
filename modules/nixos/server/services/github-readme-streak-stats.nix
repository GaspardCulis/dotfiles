{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.github-readme-streak-stats;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.github-readme-streak-stats = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "github-readme-streak-stats.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 57834;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."github-readme-streak-stats/GITHUB_TOKEN".owner = "root";
    sops.templates."github-readme-streak-stats.env" = {
      content = ''
        WHITELIST=GaspardCulis
        TOKEN=${config.sops.placeholder."github-readme-streak-stats/GITHUB_TOKEN"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      vaultwarden = {
        image = "docker.io/gaspardcs/streak-stats:latest";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.port}:80"
        ];
        environmentFiles = [
          config.sops.templates."github-readme-streak-stats.env".path
        ];
      };
    };
  };
}
