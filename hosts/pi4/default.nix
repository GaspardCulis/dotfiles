{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

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

  # User config
  users.groups.gaspard = {
    name = "gaspard";
  };
  users.users.gaspard = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    group = "gaspard";
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      # FIX: No user config file
      "gaspard" = {
        home.username = "gaspard";
        home.homeDirectory = "/home/gaspard";
        home.stateVersion = "24.11";

        programs.home-manager.enable = true;
        programs.direnv.enable = true;

        imports = [
          ../../shell
          ../../editor
        ];
      };
    };
  };

  # SOPS
  sops.defaultSopsFile = ../../secrets/pi4/default.yaml;
  sops.secrets."wireguard/private_key".owner = "root";

  system.stateVersion = "24.11";
}
