{
  pkgs,
  lib,
  ...
}: {
  imports = [./services];

  options.gasdev.server = {
    domain = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Server domain";
    };
  };

  config = {
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

    gasdev = {
      podman.enable = true;
    };
  };
}
