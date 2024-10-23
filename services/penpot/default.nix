{config, ...}: {
  services.caddy.virtualHosts."penpot.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:9001
  '';

  sops.secrets."penpot/SECRET_KEY".owner = "root";
  sops.secrets."penpot/OIDC_CLIENT_SECRET".owner = "root";
  sops.secrets."penpot/SMTP_HOST".owner = "root";
  sops.secrets."penpot/SMTP_PORT".owner = "root";
  sops.secrets."penpot/SMTP_USERNAME".owner = "root";
  sops.secrets."penpot/SMTP_PASSWORD".owner = "root";
  sops.secrets."penpot/POSTGRES_USER".owner = "root";
  sops.secrets."penpot/POSTGRES_PASSWORD".owner = "root";
  sops.secrets."penpot/AWS_ACCESS_KEY_ID".owner = "root";
  sops.secrets."penpot/AWS_SECRET_ACCESS_KEY".owner = "root";
  sops.secrets."penpot/STORAGE_ASSETS_S3_REGION".owner = "root";
  sops.secrets."penpot/STORAGE_ASSETS_S3_ENDPOINT".owner = "root";
  sops.secrets."penpot/STORAGE_ASSETS_S3_BUCKET".owner = "root";
  sops.templates."penpot.env" = {
    content = ''
      PENPOT_SECRET_KEY=${config.sops.placeholder."penpot/SECRET_KEY"}
      PENPOT_OIDC_CLIENT_SECRET=${config.sops.placeholder."penpot/OIDC_CLIENT_SECRET"}
      # SMTP
      PENPOT_SMTP_HOST=${config.sops.placeholder."penpot/SMTP_HOST"}
      PENPOT_SMTP_PORT=${config.sops.placeholder."penpot/SMTP_PORT"}
      PENPOT_SMTP_USERNAME=${config.sops.placeholder."penpot/SMTP_USERNAME"}
      PENPOT_SMTP_PASSWORD=${config.sops.placeholder."penpot/SMTP_PASSWORD"}
      # Database
      PENPOT_DATABASE_USERNAME=${config.sops.placeholder."penpot/POSTGRES_USER"}
      PENPOT_DATABASE_PASSWORD=${config.sops.placeholder."penpot/POSTGRES_PASSWORD"}
      POSTGRES_USER=${config.sops.placeholder."penpot/POSTGRES_USER"}
      POSTGRES_PASSWORD=${config.sops.placeholder."penpot/POSTGRES_PASSWORD"}
      # Storage
      AWS_ACCESS_KEY_ID=${config.sops.placeholder."penpot/AWS_ACCESS_KEY_ID"}
      AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."penpot/AWS_SECRET_ACCESS_KEY"}
      PENPOT_STORAGE_ASSETS_S3_REGION=${config.sops.placeholder."penpot/STORAGE_ASSETS_S3_REGION"}
      PENPOT_STORAGE_ASSETS_S3_BUCKET=${config.sops.placeholder."penpot/STORAGE_ASSETS_S3_BUCKET"}
      PENPOT_STORAGE_ASSETS_S3_ENDPOINT=${config.sops.placeholder."penpot/STORAGE_ASSETS_S3_ENDPOINT"}
    '';
    owner = "root";
  };

  virtualisation.oci-containers.containers = {
    penpot-frontend = {
      image = "docker.io/penpotapp/frontend:latest";
      autoStart = true;
      ports = ["127.0.0.1:9001:80"];
      volumes = [
        "penpot_assets:/opt/data/assets"
      ];
      environment = {
        PENPOT_FLAGS = "disable-login-with-password disable-registration enable-login-with-oidc";
      };
      dependsOn = [
        "penpot-backend"
        "penpot-exporter"
      ];
    };
    penpot-backend = {
      image = "docker.io/penpotapp/backend:latest";
      autoStart = true;
      volumes = [
        "penpot_assets:/opt/data/assets"
      ];
      environment = {
        PENPOT_FLAGS = "disable-login-with-password enable-login-with-oidc enable-oidc-registration enable-smtp";
        # Auth
        PENPOT_OIDC_CLIENT_ID = "penpot";
        PENPOT_OIDC_BASE_URI = "https://auth.gasdev.fr";
        PENPOT_PUBLIC_URI = "https://penpot.gasdev.fr";
        # DB
        PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
        PENPOT_REDIS_URI = "redis://penpot-redis/0";
        # Storage
        PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
        # SMTP
        PENPOT_SMTP_DEFAULT_FROM = "no-reply@gasdev.fr";
        PENPOT_SMTP_DEFAULT_REPLY_TO = "no-reply@gasdev.fr";
        PENPOT_SMTP_SSL = "true";
        PENPOT_SMTP_TLS = "true";
        # Other
        PENPOT_TELEMETRY_ENABLED = "false";
      };
      environmentFiles = [
        config.sops.templates."penpot.env".path
      ];
      dependsOn = [
        "penpot-postgres"
        "penpot-redis"
      ];
    };
    penpot-exporter = {
      image = "docker.io/penpotapp/exporter:latest";
      autoStart = true;
      environment = {
        PENPOT_PUBLIC_URI = "http://penpot-frontend";
        PENPOT_REDIS_URI = "redis://penpot-redis/0";
      };
    };
    penpot-postgres = {
      image = "docker.io/postgres:15";
      autoStart = true;
      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
        POSTGRES_DB = "penpot";
      };
      environmentFiles = [
        config.sops.templates."penpot.env".path
      ];
    };
    penpot-redis = {
      image = "docker.io/redis:7";
      autoStart = true;
    };
  };
}
