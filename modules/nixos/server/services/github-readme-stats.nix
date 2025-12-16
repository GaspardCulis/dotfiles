{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.github-readme-stats;
  domain = config.gasdev.server.domain;

  github-readme-stats =
    pkgs.buildNpmPackage
    {
      pname = "github-readme-stats";
      version = "1.0.0";
      nodejs = pkgs.nodejs_24;

      src = pkgs.fetchFromGitHub {
        owner = "anuraghazra";
        repo = "github-readme-stats";
        rev = "8994937bd139cd43b6ec431229f009f1e5204d3d";
        hash = "sha256-RcEcKPCNNCT0wqqkYwjqnNU27UAOtLhglK+J+3BHRm4=";
      };
      npmDepsHash = "sha256-RL01fYX5T7lMEZ4bEMfQ7Eb6OPq2hvPBZTRn4KQBKC8=";
      npmInstallFlags = ["-D"];
      npmPruneFlags = ["--dry-run"];
      dontNpmBuild = true;
    }
    + "/lib/node_modules/github-readme-stats";
in {
  options.gasdev.services.github-readme-stats = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "github-readme-stats.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 6857;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."github-readme-stats/GITHUB_PAT".owner = "root";
    sops.templates."github-readme-stats.env" = {
      content = ''
        WHITELIST=GaspardCulis
        PAT_1=${config.sops.placeholder."github-readme-stats/GITHUB_PAT"}
      '';
      owner = "root";
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = {
      github-readme-stats = {
        image = "localhost/github-readme-stats:latest";
        imageFile = pkgs.dockerTools.buildImage {
          name = "github-readme-stats";
          tag = "latest";

          fromImageName = "alpine";
          fromImageTag = "latest";

          copyToRoot = pkgs.buildEnv {
            name = "github-readme-stats-env";
            paths = with pkgs; [
              nodejs_24
              dockerTools.caCertificates
            ];
          };
          config = {
            WorkingDir = "/opt/app";
            Cmd = ["node" "express.js"];
          };
        };
        autoStart = true;
        volumes = [
          "${github-readme-stats}:/opt/app/"
          "${config.sops.templates."github-readme-stats.env".path}:/opt/app/.env"
        ];
        ports = ["127.0.0.1:${toString cfg.port}:9000"];
      };
    };
  };
}
