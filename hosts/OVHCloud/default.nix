{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
  ];

  environment.systemPackages = with pkgs; [
    helix
    git
  ];

  gasdev = {
    services.auth.enable = true;
    services.mail.enable = true;
    services.outline.enable = true;
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/OVHCloud/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "24.11";
}
