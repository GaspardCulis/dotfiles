{pkgs, ...}: {
  imports = [
    ./podman.nix
    ./openssh.nix
    ./plymouth.nix
    ./users
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = ["https://gasdev.cachix.org"];
    trusted-substituters = ["https://gasdev.cachix.org"];
    trusted-public-keys = ["gasdev.cachix.org-1:eBesrrBJpsMZ33OmvG4aKvfdyVkDa2OKCJ2o80IMJfE="];
  };

  time.timeZone = "Europe/Paris";

  # Default system packages

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    rsync
    unzip
    fastfetch
    uutils-coreutils-noprefix
  ];
}
