{config, ...}: {
  sops.secrets."webdav/USER_PASSWORD".owner = "${config.services.webdav.user}";
  sops.templates."webdav.env" = {
    content = ''
      USER_PASSWORD=${config.sops.placeholder."webdav/USER_PASSWORD"}
    '';
    owner = "${config.services.webdav.user}";
  };

  services.caddy.virtualHosts."webdav.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:6065
  '';

  services.webdav = {
    enable = true;
    environmentFile = config.sops.templates."webdav.env".path;
    settings = {
      address = "0.0.0.0";
      port = 6065;
      tls = false;
      behindProxy = true;
      directory = "/var/lib/webdav";
      debug = true;
      users = [
        {
          username = "gaspard";
          password = "{env}USER_PASSWORD";
          permissions = "CRUD";
        }
      ];
    };
  };
  systemd.services.webdav.serviceConfig.StateDirectory = "webdav";
  systemd.services.webdav.serviceConfig.StateDirectoryMode = "0740";
}
