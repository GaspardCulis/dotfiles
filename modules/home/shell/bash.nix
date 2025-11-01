{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.shell.bash;
in {
  options.gasdev.shell.bash = {
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
    programs.bash = {
      enable = true;
      historyFileSize = 4294967295;
      historySize = 4294967295;
      initExtra = mkIf cfg.jaaj.enable ''
        eval "$(starship init bash)"
        eval "$(zoxide init --cmd cd bash)"

        ${
          if cfg.jaaj.colors
          then inputs.jaaj-rs.packages.${pkgs.system}.lolcat
          else inputs.jaaj-rs.packages.${pkgs.system}.default
        }/bin/jaaj-rs
      '';
      bashrcExtra = ''
        [[ -z "$FUNCNEST" ]] && export FUNCNEST=100
        [[ -z "$XDG_CONFIG_HOME" ]] && export XDG_CONFIG_HOME="$HOME/.config"

        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'
      '';
      shellAliases = {
        gs = "git status";
        ga = "git add -p";
        gc = "git commit";
        gp = "git push";
        gpl = "git pull";

        ns = "nix-shell";
        nd = "nix develop";
        nsp = "nix-shell -p";

        ls = "lsd";
        l = "lsd -alh";

        ip = "ip --color=auto";
        tld = "tree -L 2";
      };
    };
    home.packages = [
      pkgs.starship
      pkgs.zoxide
      pkgs.tree
      pkgs.lsd
    ];
  };
}
