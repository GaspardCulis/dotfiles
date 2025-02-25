{...}: {
  imports = [
    ./authelia.nix
    ./garage.nix
    ./stalwart-mail.nix
    ./outline.nix
    ./uptime-kuma.nix
  ];
}
