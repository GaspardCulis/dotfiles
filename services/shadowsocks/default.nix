{
  config,
  pkgs,
  ...
}: let
  port = "8388";
in {
  sops.secrets."shadowsocks/password".owner = "root";
  sops.templates."shadowsocks/config.json" = {
    content = ''
      {
          "server": "0.0.0.0",
          "server_port": ${port},
          "password": "${config.sops.placeholder."shadowsocks/password"}",
          "method": "aes-256-gcm",
          "timeout": 300,
          "plugin": "${pkgs.shadowsocks-v2ray-plugin}/bin/v2ray-plugin",
          "plugin_opts":"server;loglevel=none",

          "local_port": ${port},
          "local_address": "127.0.0.1"
      }
    '';
    owner = "root";
  };

  services.caddy.virtualHosts."shadowsocks.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:${port}
  '';

  systemd.services = {
    shadowsocks = {
      description = "Shadowsocks tunnel";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      enable = true;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${pkgs.shadowsocks-rust}/bin/ssserver -c ${config.sops.templates."shadowsocks/config.json".path}";
      };
    };
  };
}
