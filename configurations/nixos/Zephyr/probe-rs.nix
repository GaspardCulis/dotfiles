{...}: let
  probe-rs-rules = builtins.fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    sha256 = "10lykgbhv5bpir956mdp2sp60rzykmqga0sq9wd8594shglgkw96";
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
