{
  config,
  lib,
  ...
}: let
  cfg = config.gasdev.server;
in {
  options.gasdev.server = {
    containers = lib.mkOption {
      description = "Container definitions";
      type = lib.types.attrs;
    };

    containersUser = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "User running the containers";
      default = "root"; # FIX: Should be rootless, but when switching to a normal user DNS does not work
    };
  };

  config = {
    # users.groups."${cfg.containersUser}" = {};
    # users.users."${cfg.containersUser}" = {
    #   isNormalUser = true;
    #   group = cfg.containersUser;
    #   linger = true;
    #   extraGroups = ["podman"];
    # };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = builtins.mapAttrs (name: value:
      {
        # podman.user = cfg.containersUser;
      }
      // value)
    cfg.containers;
  };
}
