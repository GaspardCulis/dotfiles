{...}: {
  imports = [
    ./podman.nix
    ./openssh.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  time.timeZone = "Europe/Paris";
}
