{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.shell.helix;
  bloated = cfg.lspProfile == "bloated";
  minimal = bloated || (cfg.lspProfile == "minimal");
in {
  options.gasdev.shell.helix = {
    enable = mkEnableOption "Enable opiniated helix config";
    lspProfile = mkOption {
      type = types.enum ["none" "minimal" "bloated"];
      description = "Defines the opiniated subset of enabled LSPs";
      default = "minimal";
    };
    wakatime = mkEnableOption "Enable wakatime integration";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx";
    };

    programs.helix = let
      languages = with pkgs;
        lib.optionals minimal [
          {
            name = "nix";
            lsPkg = nil;
            lsName = "nil";
            fmtPkg = alejandra;
            fmtCmd = ["alejandra"];
          }
          {
            name = "bash";
            lsPkg = bash-language-server;
            lsName = "bash-language-server";
            fmtPkg = shfmt;
            fmtCmd = ["shfmt"];
          }
          {
            name = "yaml";
            lsPkg = yaml-language-server;
            lsName = "yaml-language-server";
          }
          {
            name = "toml";
            lsPkg = taplo;
            lsName = "taplo";
            fmtPkg = taplo;
            fmtCmd = ["taplo" "fmt" "-"];
          }
        ]
        ++ lib.optionals (cfg.lspProfile == "bloated") [
          {
            name = "c";
            lsPkg = clang-tools;
            lsName = "clangd";
            fmtPkg = clang-tools;
            fmtCmd = ["clang-format"];
          }
          {
            name = "python";
            lsName = "ty";
            lsPkg = ty;
            fmtPkg = yapf;
            fmtCmd = ["yapf"];
          }
          {
            name = "java";
            lsPkg = jdt-language-server;
            lsName = "jdtls";
            fmtPkg = google-java-format;
            fmtCmd = ["google-java-format" "-"];
          }
          {
            name = "qml";
            lsPkg = kdePackages.qtdeclarative;
            lsName = "qmlls";
            fmtPkg = kdePackages.qtdeclarative;
            fmtCmd = ["qmlformat"];
          }
          {
            name = "wgsl";
            lsPkg = wgsl-analyzer;
            lsName = "wgsl-analyzer";
            fmtPkg = wgsl-analyzer;
            fmtCmd = ["wgslfmt"];
          }
          {
            name = "markdown";
            lsPkg = markdown-oxide;
            lsName = "markdown-oxide";
            fmtPkg = deno;
            fmtCmd = ["deno" "fmt" "-" "--ext" "md"];
          }
          {
            name = "rust";
            lsName = "rust-analyzer";
          }
          {
            name = "typst";
            lsPkg = tinymist;
            lsName = "tinymist";
          }
        ];
    in {
      enable = true;
      settings = {
        editor = {
          color-modes = true;
          cursorline = true;
          end-of-line-diagnostics = "hint";
          line-number = "relative";
          mouse = false;
          preview-completion-insert = false;
          soft-wrap.enable = true;
          inline-diagnostics.cursor-line = "error";

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            render = true;
            character = "┆";
          };

          lsp = {
            auto-signature-help = false;
            display-messages = true;
          };
        };

        keys = {
          normal = {
            backspace = {
              r = ":sh cargo run";
              b = ":sh cargo build";
              p = ":sh python src/main.py";
            };
            a = ["ensure_selections_forward" "collapse_selection" "move_char_right" "insert_mode"];
            A-R = [":clipboard-paste-replace"];
          };
        };
      };

      # Required LSP packages
      extraPackages = pkgs.lib.pipe languages [
        (map (l: l.lsPkg or null))
        (builtins.filter (p: p != null))
        pkgs.lib.unique
      ];

      languages = {
        language =
          map (
            l: let
              # Check if both formatter package and command exist
              hasFmt = (l.fmtPkg or null) != null && (l.fmtCmd or null) != null;
              # Check if an LSP name is provided
              hasLs = (l.lsName or null) != null;
            in {
              inherit (l) name;
              auto-format = true;

              # Build the language-servers list (wakatime + optional LS)
              language-servers =
                (
                  if hasLs
                  then [l.lsName]
                  else []
                )
                ++ (
                  if cfg.wakatime
                  then ["wakatime"]
                  else []
                );

              formatter = mkIf hasFmt {
                command = "${l.fmtPkg}/bin/${builtins.head l.fmtCmd}";
                args = builtins.tail l.fmtCmd;
              };
            }
          )
          languages; # This refers to your new list of objects

        language-server = {
          wakatime = mkIf cfg.wakatime {
            command = "${inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/wakatime-ls";
          };
        };
      };
    };
  };
}
