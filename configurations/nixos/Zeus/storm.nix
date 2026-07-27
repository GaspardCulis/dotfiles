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

  sops.secrets."storm-backend/STRIPE_SECRET_KEY".owner = serviceUser;
  sops.secrets."storm-backend/STRIPE_SIGNING_SECRET".owner = serviceUser;
  sops.secrets."storm-backend/ANALYTICS_WEBSITE_ID".owner = serviceUser;
  sops.secrets."storm-backend/ANALYTICS_API_URL".owner = serviceUser;
  sops.secrets."storm-backend/SMTP_HOST".owner = serviceUser;
  sops.secrets."storm-backend/SMTP_USER".owner = serviceUser;
  sops.secrets."storm-backend/SMTP_PASS".owner = serviceUser;
  sops.secrets."storm-backend/DISCORD_WEBHOOK_URL".owner = serviceUser;

  sops.templates."storm-backend.env" = {
    content = ''
      STRIPE_SECRET_KEY=${config.sops.placeholder."storm-backend/STRIPE_SECRET_KEY"}
      STRIPE_SIGNING_SECRET=${config.sops.placeholder."storm-backend/STRIPE_SIGNING_SECRET"}
      ANALYTICS_WEBSITE_ID=${config.sops.placeholder."storm-backend/ANALYTICS_WEBSITE_ID"}
      ANALYTICS_API_URL=${config.sops.placeholder."storm-backend/ANALYTICS_API_URL"}
      SMTP_HOST=${config.sops.placeholder."storm-backend/SMTP_HOST"}
      SMTP_USER=${config.sops.placeholder."storm-backend/SMTP_USER"}
      SMTP_PASS=${config.sops.placeholder."storm-backend/SMTP_PASS"}
      DISCORD_WEBHOOK_URL=${config.sops.placeholder."storm-backend/DISCORD_WEBHOOK_URL"}
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
