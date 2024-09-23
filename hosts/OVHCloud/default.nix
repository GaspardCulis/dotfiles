{pkgs, ...}: {
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

  environment.systemPackages = with pkgs; [
    helix
    git
  ];
}
