{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.tuwunel;
  domain = config.gasdev.server.domain;
  auth = config.gasdev.services.auth;
in {
  options.gasdev.services.tuwunel = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "chat.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 6167;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."tuwunel/OIDC_CLIENT_SECRET".owner = config.services.matrix-tuwunel.user;

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    networking.firewall.allowedTCPPorts = [8448];

    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        port = [cfg.port];
        server_name = domain;

        trusted_servers = ["matrix.org" "chat.ahur.ac"];

        login_with_password = false;
        # single_sso = true;
        oidc_aware_preferred = true;
        # oidc_require_client_approval = true;
        identity_provider = [
          {
            brand = "Authelia";
            icon = "https://www.authelia.com/svgs/branding/logo-cropped.svg";
            default = true;
            client_id = "tuwunel";
            client_secret_file = config.sops.secrets."tuwunel/OIDC_CLIENT_SECRET".path;
            scopes = ["openid" "profile" "email"];
            callback_url = "https://${cfg.domain}/_matrix/client/unstable/login/sso/callback/tuwunel";
            issuer_url = "https://${auth.domain}";
          }
        ];
      };
    };

    gasdev.services.auth.clients = [
      {
        client_id = "tuwunel";
        client_name = "Tuwunel";
        client_secret = "$pbkdf2-sha512$310000$rVfwgsxX.UWbb8s2GRQRyg$/FNYtcQTpXi3pqxf0TsoYz4IjZp9XEL.t2OwcXQ.oit9z1LqH/pVItbmg39gJ61H4Jw7lo0fgq9ukFP14jDWgQ";
        public = false;
        authorization_policy = "one_factor";
        redirect_uris = ["https://${cfg.domain}/_matrix/client/unstable/login/sso/callback/tuwunel"];
        require_pkce = true;
        scopes = ["openid" "profile" "email"];
        response_types = ["code"];
        response_modes = ["form_post"];
        grant_types = ["authorization_code" "refresh_token"];
        token_endpoint_auth_method = "client_secret_post";

        pre_configured_consent_duration = "1 month";
      }
    ];
  };
}
