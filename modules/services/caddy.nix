{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gasdev.services.caddy;
in {
  options.gasdev.services.caddy = {
    enable = mkEnableOption "Enable Caddy reverse proxy";
    enableOVHAcme = mkEnableOption "Enable OVH ACME provider configuration";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = inputs.caddy.packages.${pkgs.system}.caddy; # FIX: Only use thi package if enableOVHAcme

      globalConfig = mkIf cfg.enableOVHAcme ''
        acme_dns ovh {
          endpoint {$OVH_ENDPOINT}
          application_key {$OVH_APPLICATION_KEY}
          application_secret {$OVH_APPLICATION_SECRET}
          consumer_key {$OVH_CONSUMER_KEY}
        }
      '';
    };
    systemd.services.caddy = mkIf cfg.enableOVHAcme {
      serviceConfig = {
        EnvironmentFile = config.sops.templates."caddy.env".path;
      };
    };

    sops = mkIf cfg.enableOVHAcme {
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
  };
}
