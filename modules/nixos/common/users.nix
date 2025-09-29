# List of users for darwin or nixos system and their top-level configuration.
{
  flake,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (flake.inputs) self;
  mapListToAttrs = m: f:
    lib.listToAttrs (map (name: {
        inherit name;
        value = f name;
      })
      m);
in {
  options.gasdev.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "List of usernames";
    defaultText = "./configuration/home/gaspard included by default";
    default = ["gaspard"];
  };

  config = {
    # For home-manager to work.
    # https://github.com/nix-community/home-manager/issues/4026#issuecomment-1565487545
    users.users = mapListToAttrs config.gasdev.users (
      name:
        lib.optionalAttrs pkgs.stdenv.isDarwin
        {
          home = "/Users/${name}";
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          isNormalUser = true;
        }
    );

    # Enable home-manager for our user
    home-manager.users = mapListToAttrs config.gasdev.users (name: {
      imports = [(self + /configurations/home/${name}.nix)];
    });

    # All users can add Nix caches.
    nix.settings.trusted-users =
      [
        "root"
      ]
      ++ config.gasdev.users;
  };
}
