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
    server.domain = "gasdev.fr";

    openssh = {
      enable = true;
      openFirewall = true;
    };

    # FIX: Breaking due to external flakes modules
    users.gaspard.enable = true;

    services = {
      caddy = {
        enable = true;
        ovhPlugins.enable = true;
      };

      auth.enable = true;
      beszel = {
        enable = true;
        agent = {
          enable = true;
          usePodman = true;
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICls5kQQss/5W7pzOhCQRJOZlAqklfC/10mW5J9fEVWu";
        };
      };
      garage = {
        enable = true;
        settings = {
          replication_factor = 1;
          rpc_public_addr = "10.8.0.1";
        };
      };
      mail.enable = true;
      matchbox.enable = true;
      nakama.enable = true;
      outline.enable = true;
      tandoor.enable = true;
      turn-rs = {
        enable = true;
        interface = "51.75.250.6";
        openFirewall = true;
      };
      umami.enable = true;
      uptime-kuma.enable = true;
      vaultwarden.enable = true;
    };
  };

  # Proxy to Pi4
  services.caddy.virtualHosts."pi.gasdev.fr, *.pi.gasdev.fr".extraConfig = ''
    reverse_proxy 10.8.0.31:80
  '';

  # SOPS
  sops.defaultSopsFile = ../../../secrets/OVHCloud/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "24.11";
}
