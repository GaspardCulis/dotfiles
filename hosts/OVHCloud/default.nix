{...}: {
  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

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
    services.garage.enable = true;
    services.mail.enable = true;
    services.matchbox.enable = true;
    services.nakama.enable = true;
    services.openproject.enable = true;
    services.outline.enable = true;
    services.tandoor.enable = true;
    services.umami.enable = true;
    services.uptime-kuma.enable = true;
    services.vaultwarden.enable = true;
    services.webdav.enable = true;
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/OVHCloud/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "24.11";
}
