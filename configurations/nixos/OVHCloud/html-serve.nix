{config, ...}: let
  domain = config.gasdev.server.domain;
in {
  services.caddy.virtualHosts."shop.${domain}".extraConfig = ''
    root /var/www/html

    file_server

    redir / /storm
  '';
}
