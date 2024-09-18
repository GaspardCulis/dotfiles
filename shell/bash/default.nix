{
  pkgs,
  ...
} : {
  programs.bash.enable = true;
  
  home.file = {
    ".bashrc".source = ./.bashrc;
    ".bash_aliases".source = ./.bash_aliases;
    ".bash_exec".source = ./.bash_exec;
  };
  
  home.packages = [
    pkgs.starship
  ];
}

