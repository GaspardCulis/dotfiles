{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.podman;
in {
  options.gasdev.podman = {
    enable = mkEnableOption "Enable podman config";
    package = mkPackageOption pkgs "podman" {};
  };

  config = mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        package = cfg.package;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = [
      pkgs.podman-compose
    ];
  };
}
