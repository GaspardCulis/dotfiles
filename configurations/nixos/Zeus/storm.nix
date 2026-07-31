{
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;

  domain = config.gasdev.server.domain;

  serviceUser = config.storm.services.backend.user;
  servicePort = 57083;
  dbPort = 55432;
  directusPort = 8055;
  serviceDomain = "storm-backend.${domain}";
  directusDomain = "storm-admin.${domain}";
in {
  imports = [
    inputs.storm-backend.nixosModules.default
  ];

  sops.secrets."storm/backend-env".owner = serviceUser;
  sops.secrets."storm/db-env".owner = config.gasdev.server.containersUser;
  sops.secrets."storm/directus-env".owner = config.gasdev.server.containersUser;

  services.caddy.virtualHosts."${serviceDomain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString servicePort}
  '';

  services.caddy.virtualHosts."${directusDomain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString directusPort}
  '';

  storm.services.backend = {
    enable = true;
    port = servicePort;
    secretsFile = config.sops.secrets."storm/backend-env".path;
    debug = true;
  };

  virtualisation.oci-containers.containers = {
    storm-db = {
      image = "docker.io/postgres:16-alpine";
      pull = "newer";
      autoStart = true;
      ports = [
        "127.0.0.1:${toString dbPort}:5432"
      ];
      environment = {
        POSTGRES_DB = "storm";
      };
      environmentFiles = [
        config.sops.secrets."storm/db-env".path
      ];
      volumes = [
        "storm-db-data:/var/lib/postgresql/data"
      ];
    };

    storm-directus = {
      image = "docker.io/directus/directus:12";
      pull = "newer";
      autoStart = true;
      ports = [
        "127.0.0.1:${toString directusPort}:8055"
      ];
      dependsOn = ["storm-db"];
      environment = {
        DB_CLIENT = "pg";
        DB_HOST = "storm-db";
        DB_PORT = "5432";
        DB_DATABASE = "storm";
        PUBLIC_URL = "https://${directusDomain}";
        WEBSOCKETS_ENABLED = "true";
      };
      environmentFiles = [
        config.sops.secrets."storm/directus-env".path
      ];
      volumes = [
        "storm-directus-uploads:/directus/uploads"
        "storm-directus-extensions:/directus/extensions"
      ];
    };
  };
}
