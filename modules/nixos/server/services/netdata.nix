{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.netdata;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.netdata = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "monitor.${domain}";
    };
    _port = mkOption {
      type = types.ints.unsigned;
      description = "Internal container port";
      default = 43134;
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:19999
    '';

    virtualisation.oci-containers.containers = {
      netdata = {
        image = "docker.io/netdata/netdata:stable";
        pull = "newer";
        autoStart = true;
        capabilities = {
          SYS_PTRACE = true;
          SYS_ADMIN = true;
        };
        extraOptions = [
          "--pid=host"
          "--network=host"
        ];
        environment = {
          # DOCKER_HOST = "localhost:${toString cfg.port}";
        };
        ports = [
          # "127.0.0.1:${toString cfg.port}:19999"
        ];
        volumes = [
          "netdataconfig:/etc/netdata"
          "netdatalib:/var/lib/netdata"
          "netdatacache:/var/cache/netdata"

          "/:/host/root:ro,rslave"
          "/etc/passwd:/host/etc/passwd:ro"
          "/etc/group:/host/etc/group:ro"
          "/etc/localtime:/etc/localtime:ro"
          "/proc:/host/proc:ro"
          "/sys:/host/sys:ro"
          "/etc/os-release:/host/etc/os-release:ro"
          "/var/log:/host/var/log:ro"
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
          "/run/dbus:/run/dbus:ro"
        ];
      };
    };
  };
}
