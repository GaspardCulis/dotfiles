{
  config,
  lib,
  ...
}: {
  sops.secrets."outline/OIDC_CLIENT_SECRET".owner = "outline";
  sops.secrets."outline/SMTP_PASSWORD".owner = "outline";
  sops.secrets."outline/S3_SECRET_KEY".owner = "outline";

  services.caddy.virtualHosts."outline.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7143
  '';

  services.outline = {
    enable = true;
    port = 7143;
    publicUrl = "https://outline.gasdev.fr";
    forceHttps = false;

    oidcAuthentication = {
      authUrl = "https://auth.gasdev.fr/api/oidc/authorization";
      userinfoUrl = "https://auth.gasdev.fr/api/oidc/userinfo";
      tokenUrl = "https://auth.gasdev.fr/api/oidc/token";
      displayName = "Authelia";
      clientId = "outline";
      clientSecretFile = config.sops.secrets."outline/OIDC_CLIENT_SECRET".path;
      scopes = ["openid" "offline_access" "profile" "email"];
    };

    smtp = {
      host = "mail.gasdev.fr";
      port = 465;
      username = "postmaster@gasdev.fr";
      passwordFile = config.sops.secrets."outline/SMTP_PASSWORD".path;
      fromEmail = "from.outline@gasdev.fr";
      replyEmail = "reply.outline@gasdev.fr";
    };

    storage = {
      storageType = "local";
      localRootDir = "/var/lib/outline/data";
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "outline"
    ];
}
