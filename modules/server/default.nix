{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [./services];

  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
  };

  # Proxy
  environment.systemPackages = with pkgs; [
    nss.tools
  ];

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.caddy = {
    enable = true;
    package = inputs.caddy.packages.${pkgs.system}.caddy;

    globalConfig = ''
      acme_dns ovh {
        endpoint {$OVH_ENDPOINT}
        application_key {$OVH_APPLICATION_KEY}
        application_secret {$OVH_APPLICATION_SECRET}
        consumer_key {$OVH_CONSUMER_KEY}
      }
    '';
  };
  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."caddy.env".path;
    };
  };

  sops = {
    secrets."caddy/ovh_endpoint".owner = "caddy";
    secrets."caddy/ovh_application_key".owner = "caddy";
    secrets."caddy/ovh_application_secret".owner = "caddy";
    secrets."caddy/ovh_consumer_key".owner = "caddy";

    templates."caddy.env" = {
      content = ''
        OVH_ENDPOINT=${config.sops.placeholder."caddy/ovh_endpoint"}
        OVH_APPLICATION_KEY=${config.sops.placeholder."caddy/ovh_application_key"}
        OVH_APPLICATION_SECRET=${config.sops.placeholder."caddy/ovh_application_secret"}
        OVH_CONSUMER_KEY=${config.sops.placeholder."caddy/ovh_consumer_key"}
      '';
      owner = "caddy";
    };
  };
}
