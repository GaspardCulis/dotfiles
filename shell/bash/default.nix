{pkgs, ...}: {
  programs.bash = {
    enable = true;
    bashrcExtra = ". ${./.bashrc}";
  };

  home.file = {
    ".bash_aliases".source = ./.bash_aliases;
    ".bash_exec".source = ./.bash_exec;
  };

  home.packages = [
    pkgs.starship
    pkgs.zoxide
    pkgs.tree
    pkgs.lsd
  ];
}
