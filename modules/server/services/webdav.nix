{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.webdav;
in {
  options.gasdev.services.webdav = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "webdav.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 6065;
    };
    directory = mkOption {
      type = types.nonEmptyStr;
      description = "Directory data is stored in";
      default = "/var/lib/webdav";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."webdav/USER_PASSWORD".owner = "${config.services.webdav.user}";

    sops.templates."webdav.env" = {
      content = ''
        USER_PASSWORD=${config.sops.placeholder."webdav/USER_PASSWORD"}
      '';

      owner = "${config.services.webdav.user}";
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    services.webdav = {
      enable = true;

      environmentFile = config.sops.templates."webdav.env".path;

      settings = {
        address = "127.0.0.1";
        port = cfg.port;
        tls = false;
        behindProxy = true;
        directory = cfg.directory;

        users = [
          {
            username = "gaspard";
            password = "{env}USER_PASSWORD";
            permissions = "CRUD";
          }
        ];
      };
    };

    systemd.services.webdav.serviceConfig.StateDirectory = "webdav";
    systemd.services.webdav.serviceConfig.StateDirectoryMode = "0740";
  };
}
