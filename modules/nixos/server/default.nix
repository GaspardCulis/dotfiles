{pkgs, ...}: {
  imports = [./services];

  # Save on storage
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
  };

  # Proxy
  environment.systemPackages = with pkgs; [
    nss.tools
  ];

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
