{pkgs, ...}: {
  home.packages = with pkgs; [
    helix
    lsp-ai
  ];

  home.file = {
    ".config/helix/config.toml".source = ./config.toml;
    ".config/helix/languages.toml".source = ./languages.toml;
    ".config/helix/themes/jaaj.toml".source = ./themes/jaaj.toml;
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };
}
