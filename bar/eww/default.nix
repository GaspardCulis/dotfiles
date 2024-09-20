{pkgs, ...}: {
  home.file = {
    ".config/eww".source = ../eww;
    # Eww-barD script
    ".local/bin/eww-bard" = {
      source = ../../bin/eww-bard;
      executable = true;
    };
  };

  home.packages = [
    pkgs.eww
    # Script dependencies
    pkgs.jq
    pkgs.dash
    pkgs.socat
  ];
}
