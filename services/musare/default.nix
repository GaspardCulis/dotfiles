{
  pkgs,
  config,
  ...
}: let
  musare = pkgs.fetchFromGitHub {
    owner = "Musare";
    repo = "Musare";
    rev = "v3.11.0";
    hash = "sha256-RN9H7atiNOr4wqgzfwE/8hUMJ4zpgMBu3dXA37c/lH0=";
  };
  musare-backend =
    pkgs.buildNpmPackage {
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
    pkgs.buildNpmPackage {
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
  services.caddy.virtualHosts."music.gasdev.fr".extraConfig = ''
    root * ${musare-frontend}
    file_server

    @websockets {
        path /backend/*
        header Connection upgrade
        header Upgrade websocket
    }

    reverse_proxy @websockets localhost:32483

    handle_path /backend/*  {
        reverse_proxy localhost:32483
    }
  '';

  sops.secrets."musare/MONGO_USER_USERNAME".owner = "root";
  sops.secrets."musare/MONGO_USER_PASSWORD".owner = "root";
  sops.secrets."musare/MONGO_ROOT_PASSWORD".owner = "root";
  sops.secrets."musare/REDIS_PASSWORD".owner = "root";

  sops.templates."musare.env" = {
    content = ''
      MONGO_USER_USERNAME=${config.sops.placeholder."musare/MONGO_USER_USERNAME"}
      MONGO_USER_PASSWORD=${config.sops.placeholder."musare/MONGO_USER_PASSWORD"}
      MONGO_ROOT_PASSWORD=${config.sops.placeholder."musare/MONGO_ROOT_PASSWORD"}
      MONGO_INITDB_ROOT_PASSWORD=${config.sops.placeholder."musare/MONGO_ROOT_PASSWORD"}
      MONGO_INITDB_ROOT_USERNAME=admin
      MONGO_INITDB_DATABASE=musare
      REDIS_PASSWORD=meh_not_important
    '';
    owner = "root";
  };

  virtualisation.oci-containers.containers = {
    musare-backend = {
      image = "localhost/musare:backend";
      imageFile = pkgs.dockerTools.buildImage {
        name = "musare";
        tag = "backend";
        contents = [pkgs.nodejs_18 pkgs.bash];
        config = {
          Cmd = ["node" "--es-module-specifier-resolution=node" "/opt/app/index.js"];
        };
      };
      autoStart = true;
      volumes = [
        "${musare-backend}:/opt/app/"
        "${./config.json}:/opt/app/config.json"
      ];
      ports = [
        "32483:8080"
      ];
      workdir = "/opt/app";
      environmentFiles = [
        config.sops.templates."musare.env".path
      ];
      dependsOn = ["mongo" "redis"];
    };
    mongo = {
      image = "docker.io/mongo:latest";
      autoStart = true;
      volumes = [
        "${musare}/tools/docker/setup-mongo.sh:/docker-entrypoint-initdb.d/setup-mongo.sh"
        "musare-mongodb:/data/db"
      ];
      environmentFiles = [
        config.sops.templates."musare.env".path
      ];
    };
    redis = {
      image = "docker.io/redis:7";
      autoStart = true;
      cmd = ["--notify-keyspace-events" "Ex" "--requirepass" "meh_not_important" "--appendonly" "yes"];
      volumes = [
        "musare-redis:/data"
      ];
      environmentFiles = [
        config.sops.templates."musare.env".path
      ];
    };
  };
}
