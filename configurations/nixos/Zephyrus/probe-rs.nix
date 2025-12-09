{...}: let
  probe-rs-rules = builtins.fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2Ww=";
  };
in {
  users.gaspard.extraGroups = [
    "plugdev"
  ];

  services.udev = {
    extraRules = probe-rs-rules;
  };
}
