{config, ...}: {
  services.caddy.virtualHosts."grpc.nakama.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7349
  '';

  services.caddy.virtualHosts."api.nakama.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7350
  '';

  services.caddy.virtualHosts."console.nakama.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7351
  '';

  sops.secrets."nakama/DB_PASS".owner = "root";
  sops.secrets."nakama/SERVER_KEY".owner = "root";
  sops.secrets."nakama/ENCRYPTION_KEY".owner = "root";
  sops.secrets."nakama/REFRESH_ENCRYPTION_KEY".owner = "root";
  sops.secrets."nakama/HTTP_KEY".owner = "root";
  sops.secrets."nakama/CONSOLE_USER".owner = "root";
  sops.secrets."nakama/CONSOLE_PASS".owner = "root";
  sops.secrets."nakama/SIGNING_KEY".owner = "root";

  sops.templates."nakama/db.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."nakama/DB_PASS"}
    '';
    owner = "root";
  };

  sops.templates."nakama/config.yml" = {
    content = ''
      name: nakama1
      socket:
        server_key: "${config.sops.placeholder."nakama/SERVER_KEY"}"

      session:
        # 6h token expiry
        token_expiry_sec: 21600
        encryption_key: "${config.sops.placeholder."nakama/ENCRYPTION_KEY"}"
        refresh_encryption_key: "${config.sops.placeholder."nakama/REFRESH_ENCRYPTION_KEY"}"

      runtime:
        http_key: "${config.sops.placeholder."nakama/HTTP_KEY"}"

      console:
        username: "${config.sops.placeholder."nakama/CONSOLE_USER"}"
        password: "${config.sops.placeholder."nakama/CONSOLE_PASS"}"

        signing_key: "${config.sops.placeholder."nakama/SIGNING_KEY"}"
    '';
    owner = "root";
  };

  virtualisation.oci-containers.containers = {
    nakama = {
      image = "registry.heroiclabs.com/heroiclabs/nakama:latest";
      pull = "newer";
      autoStart = true;
      ports = [
        "127.0.0.1:7349:7349"
        "127.0.0.1:7350:7350"
        "127.0.0.1:7351:7351"
      ];
      volumes = [
        "nakama-data:/nakama/data"
        "${config.sops.templates."nakama/config.yml".path}:/nakama/data/config.yml"
      ];
      dependsOn = ["nakama-db"];
      environmentFiles = [
        config.sops.templates."nakama/db.env".path
      ];
      entrypoint = "/bin/sh";
      cmd = [
        "-ecx"
        ''
          /nakama/nakama migrate up --config /nakama/data/config.yml --database.address postgres:$POSTGRES_PASSWORD@nakama-db:5432/nakama && exec /nakama/nakama --config /nakama/data/config.yml --database.address postgres:$POSTGRES_PASSWORD@nakama-db:5432/nakama
        ''
      ];
    };

    nakama-db = {
      image = "docker.io/postgres:12.2-alpine";
      pull = "newer";
      autoStart = true;
      volumes = ["nakama-db:/var/lib/postgresql/data"];
      environment = {
        POSTGRES_DB = "nakama";
      };
      environmentFiles = [
        config.sops.templates."nakama/db.env".path
      ];
    };
  };
}
