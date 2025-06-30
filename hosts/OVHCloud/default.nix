{...}: {
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  networking.hostName = "OVHCloud";

  # Firewall
  networking.nftables.enable = true;
  networking.firewall.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
  ];

  gasdev = {
    openssh = {
      enable = true;
      openFirewall = true;
    };

    users.gaspard.enable = true;

    services.auth.enable = true;
    services.beszel = {
      enable = true;
      agent = {
        enable = true;
        usePodman = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICls5kQQss/5W7pzOhCQRJOZlAqklfC/10mW5J9fEVWu";
      };
    };
    services.garage = {
      enable = true;
      settings = {
        replication_factor = 2;
        rpc_public_addr = "10.8.0.1";
        bootstrap_peers = [
          "09c34a75861e794a0842f018237d1e445308c6f3488b1609717ac05815a2e41e@10.8.0.31:3901"
        ];
      };
    };
    services.mail.enable = true;
    services.matchbox.enable = true;
    services.nakama.enable = true;
    services.outline.enable = true;
    services.tandoor.enable = true;
    services.turn-rs = {
      enable = true;
      interface = "51.210.104.210";
      openFirewall = true;
    };
    services.umami.enable = true;
    services.uptime-kuma.enable = true;
    services.vaultwarden.enable = true;
  };

  # Proxy to Pi4
  services.caddy.virtualHosts."pi.gasdev.fr, *.pi.gasdev.fr".extraConfig = ''
    reverse_proxy 10.8.0.31:80
  '';

  # SOPS
  sops.defaultSopsFile = ../../secrets/OVHCloud/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "24.11";
}
