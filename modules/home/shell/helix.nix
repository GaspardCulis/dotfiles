{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.shell.helix;
in {
  options.gasdev.shell.helix = {
    enable = mkEnableOption "Enable opiniated helix config";
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
      extraPackages = with pkgs; [
        clang-tools
        rust-analyzer
        jdt-language-server
        bash-language-server
        typescript-language-server
        vscode-css-languageserver
        marksman
        kdePackages.qtdeclarative # qmlls
        python3Packages.python-lsp-server
        nil
        tinymist
        yaml-language-server
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
          with pkgs; [
            (lang {
              name = "nix";
              pkg = alejandra;
              command = ["alejandra"];
            })
            (lang {
              name = "c";
              pkg = clang-tools;
              command = ["clang-format"];
            })
            (lang {
              name = "bash";
              pkg = shfmt;
              command = ["shfmt"];
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
              name = "rust";
              pkg = rustfmt;
              command = ["rustfmt"];
            })
            (lang {
              name = "toml";
              pkg = taplo;
              command = ["taplo" "fmt" "-"];
            })
            (lang {
              name = "wgsl";
              pkg = wgsl-analyzer;
              command = ["wgslfmt"];
            })
            (lang {
              name = "python";
              pkg = yapf;
              command = ["yapf"];
            })
            (lang {
              name = "markdown";
              pkg = deno;
              command = ["deno" "fmt" "-" "--ext" "md"];
            })
            {
              name = "typst";
              auto-format = true;
            }
          ];
        language-server = {
          wgsl_analyzer = {
            command = "${pkgs.wgsl-analyzer}/bin/wgsl-analyzer";
          };
        };
      };
    };
  };
}
