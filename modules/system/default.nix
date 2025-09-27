{pkgs, ...}: {
  imports = [
    ./podman.nix
    ./openssh.nix
    ./users
    ./specialisations/steamos.nix
    ./specialisations/guest.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://gasdev.cachix.org"];
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
    neofetch
    uutils-coreutils-noprefix
  ];
}
