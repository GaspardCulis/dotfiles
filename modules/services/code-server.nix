{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.code-server;
in {
  options.gasdev.services.code-server = {
    enable = mkEnableOption "Enable VSCode server";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."code-server.pi.gasdev.fr".extraConfig = ''
      reverse_proxy 127.0.0.1:8443
    '';

    virtualization.oci-containers.containers = {
      code-server = {
        image = "lscr.io/linuxserver/code-server:latest";
        autoStart = true;
        environment = {
          PUID = "1000";
          PGID = "1000";
          PASSWORD = "temp_password";
          PROXY_DOMAIN = "code-server.pi.gasdev.fr";
        };
        ports = [
          "8443:8443"
        ];
      };
    };
  };
}
