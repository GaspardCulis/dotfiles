{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.editor.helix;
in {
  options.gasdev.editor.helix = {
    enable = mkEnableOption "Enable opiniated helix config";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx";
    };
    programs.helix = {
      enable = true;
      settings = {
        theme = "jaaj";
        editor = {
          color-modes = true;
          cursorline = true;
          end-of-line-diagnostics = "hint";
          line-number = "relative";
          mouse = false;
          preview-completion-insert = false;
          soft-wrap.enable = true;

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

      themes = {
        jaaj = {
          inherits = "sonokai";
          "ui.background" = {};
        };
      };

      # Yoinked from Ahurac's dotfiles, thx!
      extraPackages = with pkgs; [
        clang-tools
        rust-analyzer
        jdt-language-server
        bash-language-server
        marksman
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
              name = "markdown";
              pkg = mdformat;
              command = ["mdformat" "--wrap" "80" "-"];
            })
            {
              name = "typst";
              auto-format = true;
            }
          ];
      };
    };
  };
}
