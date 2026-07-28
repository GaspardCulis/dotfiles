{
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;

  domain = config.gasdev.server.domain;

  serviceUser = config.storm.services.backend.user;
  servicePort = 57083;
  serviceDomain = "storm-backend.${domain}";
in {
  imports = [
    inputs.storm-backend.nixosModules.default
  ];

  sops.secrets."storm-backend-env".owner = serviceUser;

  services.caddy.virtualHosts."${serviceDomain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString servicePort}
  '';

  storm.services.backend = {
    enable = true;
    port = servicePort;
    secretsFile = config.sops.secrets."storm-backend-env".path;
  };

  gasdev.services.nocobase.dbPort = 55432;
}
