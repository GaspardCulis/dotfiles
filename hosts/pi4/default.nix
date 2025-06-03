{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
  ];

  gasdev = {
    openssh = {
      enable = true;
      openFirewall = true;
    };

    users.gaspard.enable = true;

    services.beszel.agent = {
      enable = true;
      usePodman = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICls5kQQss/5W7pzOhCQRJOZlAqklfC/10mW5J9fEVWu";
    };
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/pi4/default.yaml;
  sops.secrets."wireguard/private_key".owner = "root";

  system.stateVersion = "24.11";
}
