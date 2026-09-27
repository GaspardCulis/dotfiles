{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.papra;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.papra = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "papra.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 1221;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."papra/AUTH_SECRET".owner = config.services.papra.user;
    sops.secrets."papra/AUTH_OIDC_CLIENT_SECRET".owner = config.services.papra.user;
    sops.secrets."papra/DATABASE_ENCRYPTION_KEY".owner = config.services.papra.user;
    sops.secrets."papra/DOCUMENT_STORAGE_DOCUMENT_KEY_ENCRYPTION_KEYS".owner = config.services.papra.user;

    sops.templates."papra.env" = {
      content = ''
        AUTH_SECRET=${config.sops.placeholder."papra/AUTH_SECRET"}
        AUTH_OIDC_CLIENT_SECRET=${config.sops.placeholder."papra/AUTH_OIDC_CLIENT_SECRET"}
        AUTH_PROVIDERS_CUSTOMS=[{"providerId": "authelia","providerName": "Authelia","providerIconUrl": "https://www.authelia.com/images/branding/logo-cropped.png","clientId": "papra","clientSecret": "${config.sops.placeholder."papra/AUTH_OIDC_CLIENT_SECRET"}","type": "oidc","discoveryUrl": "https://${config.gasdev.services.auth.domain}/.well-known/openid-configuration","scopes": ["openid", "profile", "email"]}]

        DATABASE_ENCRYPTION_KEY=${config.sops.placeholder."papra/DATABASE_ENCRYPTION_KEY"}
        DOCUMENT_STORAGE_DOCUMENT_KEY_ENCRYPTION_KEYS=${config.sops.placeholder."papra/DOCUMENT_STORAGE_DOCUMENT_KEY_ENCRYPTION_KEYS"}
      '';
      owner = config.services.papra.user;
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    services.papra = {
      enable = true;
      environment = {
        APP_BASE_URL = "https://${cfg.domain}";
        DATABASE_URL = "file:/var/lib/papra/db.sqlite";
        DOCUMENT_STORAGE_FILESYSTEM_ROOT = "/var/lib/papra/local-documents";
        PORT = cfg.port;
        SERVER_SERVE_PUBLIC_DIR = true;

        DOCUMENT_STORAGE_ENCRYPTION_IS_ENABLED = true;
        DOCUMENTS_OCR_LANGUAGES = "eng,fra";

        AUTH_IS_REGISTRATION_ENABLED = false;
        AUTH_IS_PASSWORD_RESET_ENABLED = false;
        AUTH_PROVIDERS_EMAIL_IS_ENABLED = false;
      };
      environmentFile = config.sops.templates."papra.env".path;
    };

    gasdev.services.auth.clients = [
      {
        client_id = "papra";
        client_name = "Papra";
        client_secret = "$pbkdf2-sha512$310000$bZOuOc2iUabXZHt0YG9EXg$.M9VOGl2LOsYPyzxfw9uYe5YBAHw.8VYOSpQ6maHbVaS9vETlAx3CbA/NOJoO9UT5zL04QTOI0Y29nR18kAPvA";
        public = false;
        authorization_policy = "one_factor";
        require_pkce = false;
        pkce_challenge_method = "";
        redirect_uris = ["https://${cfg.domain}/api/auth/oauth2/callback/authelia"];
        scopes = ["openid" "profile" "email"];
        response_types = ["code"];
        grant_types = ["authorization_code"];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
        pre_configured_consent_duration = "1 month";
      }
    ];
  };
}
