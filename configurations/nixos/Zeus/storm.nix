{flake, ...}: let
  inherit (flake) inputs;

  group = "storm-gear";
  stateDir = "/var/lib/storm-gear";
in {
  users.groups.${group} = {};
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 root ${group} -"
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-*"];
    externalInterface = "ens3";
  };

  containers.storm-gear = {
    path = inputs.storm-gear.nixosConfigurations.container.config.system.build.toplevel;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.57.0";
    localAddress = "192.168.57.1";

    bindMounts = {
      "${stateDir}".isReadOnly = false;

      # FIX: We don't wanna share that to the container
      "/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
    };

    # Fixes permission issues
    additionalCapabilities = [
      "CAP_BPF"
      "CAP_NET_ADMIN"
    ];

    extraFlags = [
      "--system-call-filter=bpf"
    ];

    allowedDevices = [
      # Fixes obot docker image trying to access /dev/console and getting Permission denied
      {
        node = "/dev/console";
        modifier = "rwm";
      }
      # Fixes internal rootless container TAP networking permission issues
      {
        node = "/dev/net/tun";
        modifier = "rwm";
      }
    ];
  };

  services.caddy.virtualHosts = let
    subDomains = ["admin" "backend" "mcp"];
  in
    builtins.listToAttrs (builtins.map (v: {
        name = "${v}.stormvario.fr";
        value = {
          extraConfig = ''
            reverse_proxy 192.168.57.1:80

          '';
        };
      })
      subDomains);
}
