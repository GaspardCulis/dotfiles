{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = [
    ./hardware-configuration.nix
  ];

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

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
        home.stateVersion = "24.05";

        programs.home-manager.enable = true;
        programs.direnv.enable = true;

        imports = [
          ../../shell
          ../../editor
        ];
      };
    };
  };

  system.stateVersion = "24.11";
}
