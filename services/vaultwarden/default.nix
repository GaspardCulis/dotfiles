{config, ...}: {
  services.caddy.virtualHosts."vault.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:9092
  '';

  sops.secrets."vaultwarden/ADMIN_TOKEN".owner = "root";
  sops.secrets."vaultwarden/SMTP_USERNAME".owner = "root";
  sops.secrets."vaultwarden/SMTP_PASSWORD".owner = "root";
  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/ADMIN_TOKEN"}
      SMTP_USERNAME=${config.sops.placeholder."vaultwarden/SMTP_USERNAME"}
      SMTP_PASSWORD=${config.sops.placeholder."vaultwarden/SMTP_PASSWORD"}
    '';
    owner = "root";
  };

  virtualisation.oci-containers.containers = {
    vaultwarden = {
      image = "docker.io/vaultwarden/server:latest-alpine";
      autoStart = true;
      ports = [
        "127.0.0.1:9092:80"
      ];
      volumes = [
        "vaultwarden-data:/data/"
      ];
      environment = {
        SIGNUPS_ALLOWED = "false";
        DOMAIN = "http://vault.gasdev.fr";
        # SMTP
        SMTP_HOST = "mail.gasdev.fr";
        SMTP_PORT = "465";
        SMTP_FROM = "vaultwarden@gasdev.fr";
        SMTP_SECURITY = "force_tls";
      };
      environmentFiles = [
        config.sops.templates."vaultwarden.env".path
      ];
    };
  };
}
