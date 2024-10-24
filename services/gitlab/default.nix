{config, ...}: let
  port = 8086;
in {
  sops.secrets."gitlab/DATABASE_PASSWORD".owner = "gitlab";
  sops.secrets."gitlab/INITIAL_ROOT_PASSWORD".owner = "gitlab";
  sops.secrets."gitlab/SECRET_KEY".owner = "gitlab";
  sops.secrets."gitlab/OTP_KEY".owner = "gitlab";
  sops.secrets."gitlab/DB_KEY".owner = "gitlab";
  sops.secrets."gitlab/JWS_KEY".owner = "gitlab";

  services.caddy.virtualHosts."git.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString port}
  '';

  services.gitlab = {
    enable = true;
    port = port;
    databasePasswordFile = config.sops.secrets."gitlab/DATABASE_PASSWORD".path;
    initialRootPasswordFile = config.sops.secrets."gitlab/INITIAL_ROOT_PASSWORD".path;
    secrets = {
      secretFile = config.sops.secrets."gitlab/SECRET_KEY".path;
      otpFile = config.sops.secrets."gitlab/OTP_KEY".path;
      dbFile = config.sops.secrets."gitlab/DB_KEY".path;
      jwsFile = config.sops.secrets."gitlab/JWS_KEY".path;
    };
  };
}
