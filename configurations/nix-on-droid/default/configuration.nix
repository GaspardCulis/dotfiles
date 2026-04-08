{
  flake,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    substituters = ["https://gasdev.cachix.org"];
    trustedPublicKeys = ["gasdev.cachix.org-1:eBesrrBJpsMZ33OmvG4aKvfdyVkDa2OKCJ2o80IMJfE="];
  };

  # Simply install just the packages
  environment.packages = with pkgs; [
    git
    gawk
    openssh
    cachix
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  time.timeZone = "Europe/Paris";

  user.userName = pkgs.lib.mkForce "gaspard";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit flake;};
    sharedModules = [
      inputs.stylix.homeModules.default
      self.homeModules.default
    ];
  };

  stylix = {
    enable = true;
    homeManagerIntegration.autoImport = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
    fonts = {
      sizes.terminal = 10;

      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
