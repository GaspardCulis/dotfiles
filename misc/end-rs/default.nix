{
  inputs,
  pkgs,
  ...
}: {
  home.file = {
    ".config/end-rs/config.toml".source = ./config.toml;
  };

  home.packages = [
    inputs.end-rs
    pkgs.libnotify
    pkgs.qogir-icon-theme
  ];
}
