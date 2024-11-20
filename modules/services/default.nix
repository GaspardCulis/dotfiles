{...}: {
  imports = [
    ./outline.nix
    ./pi-hole.nix
  ];

  config = {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
