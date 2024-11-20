{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    podman-compose
    helix
    unzip
    htop
    ncdu
    wget
    git
  ];

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

  # Podman
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/pi4/default.yaml;
  sops.secrets."wireguard/private_key".owner = "root";

  # Wireguard
  networking.firewall = {
    allowedUDPPorts = [51820];
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.8.0.31/32"];
      listenPort = 51820; # Should match firewall allowedUDPPorts
      privateKeyFile = config.sops.secrets."wireguard/private_key".path;

      peers = [
        {
          publicKey = "KLULII6VEUWMhyIba6oxxHdZsVP3TMVlNY1Vz49q7jg=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "vpn.gasdev.fr:993";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  system.stateVersion = "24.11";
}
