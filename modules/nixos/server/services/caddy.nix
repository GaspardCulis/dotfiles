{
  config,
  flake,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.services.caddy;
in {
  options.gasdev.services.caddy = {
    enable = mkEnableOption "Enable service";
    ovhPlugins = {
      enable = mkEnableOption "Use Patched Caddy NixOS flake";
    };
  };

  config = mkIf cfg.enable {
    services.caddy =
      {
        enable = true;
      }
      // lib.optionalAttrs cfg.ovhPlugins.enable {
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

    sops = mkIf cfg.ovhPlugins.enable {
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

    systemd.services.caddy = mkIf cfg.ovhPlugins.enable {
      serviceConfig = {
        EnvironmentFile = config.sops.templates."caddy.env".path;
      };
    };
  };
}
