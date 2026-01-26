{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.wakapi;
  domain = config.gasdev.server.domain;
  auth = config.gasdev.services.auth;
in {
  options.gasdev.services.wakapi = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "wakatime.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 34847;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."wakapi/WAKAPI_PASSWORD_SALT".owner = "root";
    sops.secrets."wakapi/OIDC_CLIENT_SECRET".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."wakapi.env" = {
      content = ''
        WAKAPI_PUBLIC_URL=https://${cfg.domain}

        WAKAPI_PASSWORD_SALT=${config.sops.placeholder."wakapi/WAKAPI_PASSWORD_SALT"}

        WAKAPI_OIDC_PROVIDERS_0_NAME=authelia
        WAKAPI_OIDC_PROVIDERS_0_DISPLAY_NAME=Authelia
        WAKAPI_OIDC_PROVIDERS_0_CLIENT_ID=wakapi
        WAKAPI_OIDC_PROVIDERS_0_CLIENT_SECRET=${config.sops.placeholder."wakapi/OIDC_CLIENT_SECRET"}
        WAKAPI_OIDC_PROVIDERS_0_ENDPOINT=https://${auth.domain}

        WAKAPI_ALLOW_SIGNUP=false
        WAKAPI_DISABLE_LOCAL_AUTH=true

        WAKAPI_LEADERBOARD_REQUIRE_AUTH=true
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      wakapi = {
        image = "ghcr.io/muety/wakapi:latest";
        pull = "newer";
        autoStart = true;
        ports = ["127.0.0.1:${toString cfg.port}:3000"];
        volumes = [
          "wakapi-data:/data"
        ];
        environmentFiles = [
          config.sops.templates."wakapi.env".path
        ];
      };
    };

    gasdev.services.auth.clients = [
      {
        client_id = "wakapi";
        client_name = "Wakapi";
        client_secret = "$pbkdf2-sha512$310000$GjNk681cOHH0qFRyn3YWzw$.fIOz5lxdXZMjlXrvvg/ESzPhMGAWwXGGi6snVFYN3B3UXv22xVMQY4vosVjKYbeMWzggzDK.ETBeqRH4IYmIQ";
        public = false;
        authorization_policy = "one_factor";
        redirect_uris = ["https://${cfg.domain}/oidc/authelia/callback"];
        scopes = ["openid" "profile" "email"];
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
  };
}
