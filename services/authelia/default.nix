{...}: {
  sops.secrets."authelia/JWT_SECRET".owner = "root";
  sops.secrets."authelia/SMTP_PASSWORD".owner = "root";
  sops.secrets."authelia/SESSION_SECRET".owner = "root";
  sops.secrets."authelia/STORAGE_PASSWORD".owner = "root";
  sops.secrets."authelia/STORAGE_ENCRYPTION_KEY".owner = "root";
  sops.secrets."authelia/OIDC_HMAC_SECRET".owner = "root";
  sops.secrets."authelia/OIDC_JWKS_PRIVATE_KEY".owner = "root";

  services.caddy.virtualHosts."auth.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:9091
  '';

  virtualisation.oci-containers.containers = {
    authelia = {
      image = "docker.io/authelia/authelia:latest";
      pull = "newer";
      autoStart = true;
      ports = ["127.0.0.1:9091:9091"];
      environment = {
        AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE = "/secrets/JWT_SECRET";
        AUTHELIA_SESSION_SECRET_FILE = "/secrets/SESSION_SECRET";
        # AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = "/secrets/STORAGE_PASSWORD";
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = "/secrets/STORAGE_ENCRYPTION_KEY";
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = "/secrets/SMTP_PASSWORD";
        AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE = "/secrets/OIDC_HMAC_SECRET";

        X_AUTHELIA_CONFIG_FILTERS = "template";
      };
      volumes = [
        "authelia-data:/data"
        "/run/secrets/authelia:/secrets"
        "/etc/authelia/configuration.yml:/config/configuration.yml"
      ];
    };
  };

  environment.etc."authelia/configuration.yml".text = builtins.readFile ./configuration.yml;
}
