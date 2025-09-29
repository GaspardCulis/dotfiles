{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.musare;

  musare = pkgs.fetchFromGitHub {
    owner = "Musare";
    repo = "Musare";
    rev = "v3.11.0";
    hash = "sha256-RN9H7atiNOr4wqgzfwE/8hUMJ4zpgMBu3dXA37c/lH0=";
  };
  musare-backend =
    pkgs.buildNpmPackage
    {
      pname = "musare-backend";
      version = "4.7.0";
      nodejs = pkgs.nodejs_18;

      src =
        musare
        + "/backend";

      npmDepsHash = "sha256-cxvK2Zp0iOA9qPg8NaCEcOsxmaU1/l/dvnfwUEq2BuE=";
      dontNpmBuild = true;
    }
    + "/lib/node_modules/musare-backend";
  musare-frontend =
    pkgs.buildNpmPackage
    {
      pname = "musare-frontend";
      version = "4.7.0";

      src =
        musare
        + "/frontend";

      npmDepsHash = "sha256-R1vxio66W/8WN6pFRbwuOv0Z4/V4cnwBqhXlRygj7Js=";
      npmBuildScript = "prod";
    }
    + "/lib/node_modules/musare-frontend/build";
in {
  options.gasdev.services.musare = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "music.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 32483;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."musare/APP_SECRET".owner = "root";
    sops.secrets."musare/YOUTUBE_API_KEY".owner = "root";
    sops.secrets."musare/SPOTIFY_CLIENT_ID".owner = "root";
    sops.secrets."musare/SPOTIFY_CLIENT_SECRET".owner = "root";
    sops.secrets."musare/MONGO_USER_USERNAME".owner = "root";
    sops.secrets."musare/MONGO_USER_PASSWORD".owner = "root";
    sops.secrets."musare/MONGO_ROOT_PASSWORD".owner = "root";
    sops.secrets."musare/REDIS_PASSWORD".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      root * ${musare-frontend}
      file_server

      @websockets {
          path /backend/*
      }

      reverse_proxy @websockets localhost:${toString cfg.port}

      handle_path /backend/*  {
          reverse_proxy localhost:${toString cfg.port}
      }
    '';

    sops.templates."musare/.env" = {
      content = ''
        MONGO_USER_USERNAME=${config.sops.placeholder."musare/MONGO_USER_USERNAME"}
        MONGO_USER_PASSWORD=${config.sops.placeholder."musare/MONGO_USER_PASSWORD"}
        MONGO_ROOT_PASSWORD=${config.sops.placeholder."musare/MONGO_ROOT_PASSWORD"}
        MONGO_INITDB_ROOT_PASSWORD=${config.sops.placeholder."musare/MONGO_ROOT_PASSWORD"}
        MONGO_INITDB_ROOT_USERNAME=admin
        MONGO_INITDB_DATABASE=musare
        REDIS_PASSWORD=${config.sops.placeholder."musare/REDIS_PASSWORD"}
      '';
      owner = "root";
    };
    sops.templates."musare/config.json" = {
      content = ''
        {
          "configVersion": 12,
          "migration": false,
          "secret": "${config.sops.placeholder."musare/APP_SECRET"}",
          "port": 8080,
          "url": {
            "host": "${cfg.domain}",
            "secure": true
          },
          "apis": {
            "youtube": {
              "key": "${config.sops.placeholder."musare/YOUTUBE_API_KEY"}"
            },
            "spotify": {
              "clientId": "${config.sops.placeholder."musare/SPOTIFY_CLIENT_ID"}",
              "clientSecret": "${config.sops.placeholder."musare/SPOTIFY_CLIENT_SECRET"}"
            }
          },
          "mongo": {
            "host": "musare-mongo"
          },
          "redis": {
            "url": "redis://musare-redis:6379/0"
          }
        }
      '';
    };

    virtualisation.oci-containers.containers = {
      musare-backend = {
        image = "localhost/musare:backend";
        imageFile = pkgs.dockerTools.buildImage {
          name = "musare";
          tag = "backend";
          copyToRoot = pkgs.buildEnv {
            name = "musare-backend-env";
            paths = with pkgs; [
              nodejs_18
              curl
              bash
            ];
          };
          config = {
            Cmd = ["node" "--es-module-specifier-resolution=node" "/opt/app/index.js"];
          };
        };
        autoStart = true;
        volumes = [
          "${musare-backend}:/opt/app/"
          "${config.sops.templates."musare/config.json".path}:/opt/app/config/local.json"
        ];
        ports = [
          "127.0.0.1:${toString cfg.port}:8080"
        ];
        workdir = "/opt/app";
        environment = {
          NODE_TLS_REJECT_UNAUTHORIZED = "0";
        };
        environmentFiles = [
          config.sops.templates."musare/.env".path
        ];
        dependsOn = ["musare-mongo" "musare-redis"];
      };
      musare-mongo = {
        image = "docker.io/mongo:latest";
        autoStart = true;
        volumes = [
          "${musare}/tools/docker/setup-mongo.sh:/docker-entrypoint-initdb.d/setup-mongo.sh"
          "musare-mongodb:/data/db"
        ];
        environmentFiles = [
          config.sops.templates."musare/.env".path
        ];
      };
      musare-redis = {
        image = "docker.io/bitnami/redis:latest";
        autoStart = true;
        volumes = [
          "musare-redis:/data"
        ];
        environment = {
          REDIS_EXTRA_FLAGS = "--notify-keyspace-events Ex --appendonly yes";
        };
        environmentFiles = [
          config.sops.templates."musare/.env".path
        ];
      };
    };
  };
}
