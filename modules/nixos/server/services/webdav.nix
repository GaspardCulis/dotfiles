{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.webdav;
  domain = config.gasdev.server.domain;
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
    users = mkOption {
      type = types.listOf types.attrs;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = lib.mkMerge [
      (builtins.listToAttrs
        (builtins.map (x: {
            name = x.pass_sops_key;
            value = {owner = config.services.webdav.user;};
          })
          cfg.users))
    ];

    sops.templates."webdav.env" = {
      content = builtins.concatStringsSep "\n" (
        builtins.map (x: "PASSWORD_${x.name}=${config.sops.placeholder."${x.pass_sops_key}"}") cfg.users
      );

      owner = "${config.services.webdav.user}";
    };

    # FIX: Thats an ugly fix
    services.caddy.virtualHosts."http://${cfg.domain}".extraConfig = ''
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

        users = builtins.map (x: ({
            username = x.name;
            password = "{env}PASSWORD_${x.name}";
            permissions = "CRUD";
          }
          // (lib.optionalAttrs (builtins.hasAttr "subdir" x) {
            directory = "${cfg.directory}/${x.subdir}";
          })))
        cfg.users;
      };
    };

    systemd.services.webdav.serviceConfig.StateDirectory = "webdav";
    systemd.services.webdav.serviceConfig.StateDirectoryMode = "0740";
  };
}
