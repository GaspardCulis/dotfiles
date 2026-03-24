{...}: let
  probe-rs-rules = builtins.fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    sha256 = "1q7ryhl27lalbzzaifxaf0gb18xfzwvpk34sg8l2s1xinb4rr9fi";
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
