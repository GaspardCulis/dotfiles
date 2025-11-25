{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.shell.helix;
  bloated = cfg.lspProfile == "bloated";
  minimal = bloated || (cfg.lspProfile == "minimal");
in {
  options.gasdev.shell.helix = {
    enable = mkEnableOption "Enable opiniated helix config";
    lspProfile = mkOption {
      type = types.enum ["none" "minimal" "bloated"];
      description = "Defines the enabled LSPs based on a certain profile";
      default = "minimal";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx";
    };
    programs.helix = {
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

      # Yoinked from Ahurac's dotfiles, thx!
      extraPackages = with pkgs;
        lib.optionals minimal [
          bash-language-server
          marksman
          nil
          yaml-language-server
        ]
        ++ lib.optionals bloated [
          clang-tools
          rust-analyzer
          python3Packages.python-lsp-server
          jdt-language-server
          kdePackages.qtdeclarative # qmlls
          tinymist # Typst
          typescript-language-server
          vscode-css-languageserver
        ];
      languages = {
        language = let
          lang = {
            name,
            pkg,
            command,
          }: {
            inherit name;
            formatter = {
              command = "${pkg}/bin/" + builtins.elemAt command 0;
              args = lib.lists.drop 1 command;
            };
            auto-format = true;
          };
        in
          with pkgs;
            lib.optionals minimal [
              (lang {
                name = "nix";
                pkg = alejandra;
                command = ["alejandra"];
              })
              (lang {
                name = "bash";
                pkg = shfmt;
                command = ["shfmt"];
              })
              (lang {
                name = "toml";
                pkg = taplo;
                command = ["taplo" "fmt" "-"];
              })
              (lang {
                name = "markdown";
                pkg = deno;
                command = ["deno" "fmt" "-" "--ext" "md"];
              })
            ]
            ++ lib.optionals (cfg.lspProfile == "bloated") [
              (lang {
                name = "c";
                pkg = clang-tools;
                command = ["clang-format"];
              })
              (lang {
                name = "rust";
                pkg = rustfmt;
                command = ["rustfmt"];
              })
              (lang {
                name = "python";
                pkg = yapf;
                command = ["yapf"];
              })
              (lang {
                name = "java";
                pkg = google-java-format;
                command = ["google-java-format" "-"];
              })
              (lang {
                name = "qml";
                pkg = kdePackages.qtdeclarative;
                command = ["qmlformat"];
              })
              (lang {
                name = "wgsl";
                pkg = wgsl-analyzer;
                command = ["wgslfmt"];
              })
              {
                name = "typst";
                auto-format = true;
              }
            ];

        language-server = mkIf minimal {
          wgsl_analyzer = mkIf bloated {
            command = "${pkgs.wgsl-analyzer}/bin/wgsl-analyzer";
          };
        };
      };
    };
  };
}
