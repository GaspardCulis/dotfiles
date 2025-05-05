{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.khoj;
in {
  options.gasdev.services.khoj = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "chat.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 42110;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."khoj/OPENAI_API_KEY".owner = "root";
    sops.secrets."khoj/OPENAI_BASE_URL".owner = "root";
    sops.secrets."khoj/ADMIN_EMAIL".owner = "root";
    sops.secrets."khoj/ADMIN_PASSWORD".owner = "root";
    sops.secrets."khoj/DJANGO_SECRET_KEY".owner = "root";

    sops.templates."khoj.env" = {
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."khoj/OPENAI_API_KEY"}
        OPENAI_BASE_URL=${config.sops.placeholder."khoj/OPENAI_BASE_URL"}
        KHOJ_DJANGO_SECRET_KEY=${config.sops.placeholder."khoj/DJANGO_SECRET_KEY"}
        KHOJ_ADMIN_EMAIL=${config.sops.placeholder."khoj/ADMIN_EMAIL"}
        KHOJ_ADMIN_PASSWORD=${config.sops.placeholder."khoj/ADMIN_PASSWORD"}
      '';
      owner = "root";
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = {
      khoj-db = {
        image = "docker.io/pgvector/pgvector:pg15";
        pull = "newer";
        autoStart = true;
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
        };
        volumes = [
          "khoj-db:/var/lib/postgresql/data/"
        ];
      };

      khoj-sandbox = {
        image = "ghcr.io/khoj-ai/terrarium:latest";
        # pull = "newer";
        autoStart = true;
      };

      khoj-search = {
        image = "docker.io/searxng/searxng:latest";
        # pull = "newer";
        autoStart = true;
        environment = {
          SEARXNG_BASE_URL = "http://localhost:8080/";
        };
        volumes = [
          "khoj_search:/etc/searxng"
        ];
      };

      khoj-server = {
        image = "ghcr.io/khoj-ai/khoj:latest";
        # pull = "newer";
        autoStart = true;
        dependsOn = ["khoj-db"];
        ports = ["127.0.0.1:${toString cfg.port}:42110"];
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
          POSTGRES_HOST = "khoj-db";
          POSTGRES_PORT = "5432";

          KHOJ_DEBUG = "False";
          KHOJ_NO_HTTPS = "1";

          KHOJ_TERRARIUM_URL = "http://khoj-sandbox:8080";
          KHOJ_SEARXNG_URL = "http://khoj-search:8080";

          KHOJ_DOMAIN = "${cfg.domain}";
        };
        environmentFiles = [
          config.sops.templates."khoj.env".path
        ];
        volumes = [
          "khoj_config:/root/.khoj/"
          "khoj_models:/root/.cache/torch/sentence_transformers"
          "khoj_models:/root/.cache/huggingface"
        ];
        workdir = "/app";
        cmd = ["--host" "0.0.0.0" "--port" "42110" "-vv" "--non-interactive"];
      };
    };
  };
}
