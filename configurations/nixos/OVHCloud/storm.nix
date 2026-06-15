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

  sops.secrets."storm-backend/STRIPE_SECRET".owner = serviceUser;
  sops.secrets."storm-backend/ANALYTICS_WEBSITE_ID".owner = serviceUser;
  sops.secrets."storm-backend/ANALYTICS_API_URL".owner = serviceUser;
  sops.secrets."storm-backend/STMP_HOST".owner = serviceUser;
  sops.secrets."storm-backend/SMTP_USER".owner = serviceUser;
  sops.secrets."storm-backend/SMTP_PASS".owner = serviceUser;

  sops.templates."storm-backend.env" = {
    content = ''
      STRIPE_SECRET=${config.sops.placeholder."storm-backend/STRIPE_SECRET"}
      ANALYTICS_WEBSITE_ID=${config.sops.placeholder."storm-backend/ANALYTICS_WEBSITE_ID"}
      ANALYTICS_API_URL=${config.sops.placeholder."storm-backend/ANALYTICS_API_URL"}
      STMP_HOST=${config.sops.placeholder."storm-backend/SMTP_HOST"}
      STMP_USER=${config.sops.placeholder."storm-backend/SMTP_USER"}
      STMP_PASS=${config.sops.placeholder."storm-backend/SMTP_PASS"}
    '';
    owner = serviceUser;
  };

  services.caddy.virtualHosts."${serviceDomain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString servicePort}
  '';

  storm.services.backend = {
    enable = true;
    port = servicePort;
    secretsFile = config.sops.templates."storm-backend.env".path;
  };
}
