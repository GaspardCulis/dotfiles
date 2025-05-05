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
      languagePacks = ["fr" "en-US"];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

        ExtensionSettings = with builtins; let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
        in
          listToAttrs ([
              (extension "ublock-origin" "uBlock0@raymondhill.net")
              (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            ]
            ++ (
              if cfg.progressiveWebApps.enable
              then [(extension "pwas-for-firefox" "firefoxpwa@filips.si")]
              else []
            ));

        Preferences = let
          lock-false = {
            Value = false;
            Status = "locked";
          };
          lock-true = {
            Value = true;
            Status = "locked";
          };
        in {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        };
      };

      profiles."gaspard" = mkIf cfg.profiles.gaspard.enable {
        isDefault = true;
        search = {
          force = true; # Avoid HM complaining about `search.json.mozlz4`
          default = "ddg";
          engines = {
            "GitHub" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "https://github.githubassets.com/favicons/favicon.png";
              definedAliases = ["@gh"];
            };

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
              icon = "https://crates.io/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@cr"];
            };

            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
            "Wikipedia".metaData.alias = "@w";
          };
        };
      };
    };
  };
}
