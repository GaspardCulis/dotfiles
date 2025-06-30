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
          "c1166e37e36ac85369cd3a9fd1fb44f372869a078ce9e8ee642d00b3fb87dc01@10.8.0.31:3901"
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
