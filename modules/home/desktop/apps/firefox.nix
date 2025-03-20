# Mostly yoinked from Zhaith-Izaliel config, thx!
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.firefox;
in {
  options.gasdev.desktop.apps.firefox = {
    enable = mkEnableOption "Enable opiniated firefox config";

    package = mkPackageOption pkgs "firefox" {};

    progressiveWebApps = {
      enable = mkEnableOption "PWA support in Firefox. You need to install the PWA extension on Firefox";
      package = mkPackageOption pkgs "firefoxpwa" {};
    };

    profiles.gaspard = {
      enable = mkEnableOption "Gaspard Firefox profile";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional cfg.progressiveWebApps.enable cfg.progressiveWebApps.package;

    programs.firefox = {
      enable = true;
      package = cfg.package;
      nativeMessagingHosts = optional cfg.progressiveWebApps.enable cfg.progressiveWebApps.package;

      profiles."gaspard" = mkIf cfg.profiles.gaspard.enable {
        isDefault = true;
        search = {
          default = "DuckDuckGo";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };

            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@no"];
            };

            "MyNixOS" = {
              urls = [
                {
                  template = "https://mynixos.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@nm"];
            };

            "Crates.io" = {
              urls = [
                {
                  template = "https://crates.io/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              iconUpdateURL = "https://crates.io/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@cr"];
            };

            "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            "Wikipedia".metaData.alias = "@w";
          };
        };
      };
    };
  };
}
