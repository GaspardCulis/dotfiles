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
  };

  services.caddy.virtualHosts."admin.stormvario.fr backend.stormvario.fr".extraConfig = ''
    reverse_proxy 192.168.57.1:80
  '';
}
