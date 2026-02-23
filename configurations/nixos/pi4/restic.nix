{config, ...}: let
  port = 8357;
in {
  sops.secrets."restic/htpasswd".owner = "restic";

  networking.firewall = {
    allowedTCPPorts = [port];
  };

  services.restic.server = {
    enable = true;
    dataDir = "/mnt/Backups/restic";
    listenAddress = "10.8.0.31:${toString port}";
    htpasswd-file = config.sops.secrets."restic/htpasswd".path;
  };
}
