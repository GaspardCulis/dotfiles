{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pi4";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos"
  ];

  gasdev = {
    openssh = {
      enable = true;
      openFirewall = true;
    };

    users.gaspard.enable = true;

    services = {
      beszel.agent = {
        enable = true;
        usePodman = true;
        openFirewall = true;
        address = "0.0.0.0";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICls5kQQss/5W7pzOhCQRJOZlAqklfC/10mW5J9fEVWu";
        extraFilesystems = ["/mnt"];
      };

      garage = {
        enable = true;
        expose = false;
        settings = {
          replication_factor = 2;
          rpc_public_addr = "10.8.0.31";
          data_dir = "/mnt/garage/data";
          metadata_dir = "/mnt/garage/meta";
        };
      };

      webdav = {
        enable = true;
        directory = "/mnt/webdav";
      };
    };
  };

  services.caddy.globalConfig = ''
    auto_https off
    servers {
    	trusted_proxies static 10.8.0.0/24
    }
  '';

  # SOPS
  sops.defaultSopsFile = ../../secrets/pi4/default.yaml;
  sops.secrets."wireguard/private_key".owner = "root";

  system.stateVersion = "24.11";
}
