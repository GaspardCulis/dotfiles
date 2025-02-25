{...}: {
  imports = [
    ./authelia.nix
    ./garage.nix
    ./nakama.nix
    ./stalwart-mail.nix
    ./outline.nix
    ./uptime-kuma.nix
    ./vaultwarden.nix
  ];
}
