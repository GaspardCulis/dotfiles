{pkgs, ...}: {
  imports = [
    ./podman.nix
    ./openssh.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  time.timeZone = "Europe/Paris";

  # Default system packages

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    unzip
    neofetch
  ];
}
