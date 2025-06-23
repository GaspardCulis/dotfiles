{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.shell.fish;
in {
  options.gasdev.shell.fish = {
    enable = mkEnableOption "Enable opiniated bash config";
    jaaj = {
      enable = mkOption {
        description = "Enable jaaj-rs integration";
        type = types.bool;
        default = true;
      };
      colors = mkOption {
        description = "Enable package lolcat feature";
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      functions = {
        fish_greeting = {
          body =
            if cfg.jaaj.enable
            then ''
              ${
                if cfg.jaaj.colors
                then inputs.jaaj-rs.packages.${pkgs.system}.lolcat
                else inputs.jaaj-rs.packages.${pkgs.system}.default
              }/bin/jaaj-rs''
            else "";
        };
      };

      shellInit = ''
        source (${pkgs.starship}/bin/starship init fish --print-full-init | psub)
        ${pkgs.zoxide}/bin/zoxide init --cmd cd fish | source
      '';
      shellAbbrs = {
        gs = "git status";
        ga = "git add -p";
        gc = "git commit";
        gp = "git push";
        gpl = "git pull";

        ns = "nix-shell";
        nsp = "nix-shell -p";

        tld = "tree -L 2";
      };

      shellAliases = rec {
        ls = "${pkgs.lsd}/bin/lsd";
        l = "${ls} -alh";

        ip = "ip --color=auto";
      };
    };

    home.packages = [
      pkgs.lsd
    ];
  };
}
