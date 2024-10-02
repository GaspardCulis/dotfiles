# TODO: Run as different user
{...}: {
  sops.secrets."garage/RPC_SECRET".owner = "root";

  services.caddy.virtualHosts."*.s3.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:3900
  '';

  services.caddy.virtualHosts."*.s3web.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:3902
  '';

  virtualisation.oci-containers.containers = {
    garage = {
      image = "docker.io/dxflrs/garage:v1.0.0";
      autoStart = true;
      ports = [
        "127.0.0.1:3900:3900"
        "127.0.0.1:3901:3901"
        "127.0.0.1:3902:3902"
      ];
      volumes = [
        "/etc/garage.toml:/etc/garage.toml"
        "/var/lib/garage/meta:/var/lib/garage/meta"
        "/var/lib/garage/data:/var/lib/garage/data"
        "/run/secrets/garage/RPC_SECRET:/run/secrets/garage/RPC_SECRET"
      ];
    };
  };

  environment.etc."garage.toml".text = builtins.readFile ./garage.toml;
  systemd.tmpfiles.rules = [
    "d /var/lib/garage/meta 0700 root root -"
    "d /var/lib/garage/data 0700 root root -"
  ];
}
