{...}: let
  probe-rs-rules = builtins.fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    sha256 = "12i970v414225nl6i1szjfxwf5w0wzmw7r1cgzlni6wvjxvnag6a";
  };
in {
  users.groups.plugdev.name = "plugdev";
  gasdev.users.gaspard.extraGroups = [
    "plugdev"
  ];

  services.udev = {
    extraRules = builtins.readFile probe-rs-rules;
  };
}
