{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.jaajcorp.services.pi-hole;
  apConfigFile = config.sops.templates."${cfg.ap.pskSopsKey}".path;
in {
  options.jaajcorp.services.pi-hole = {
    enable = mkEnableOption "Enable pi-hole service";
    ap = {
      enable = mkEnableOption "Enable wireless access point";
      internetIface = mkOption {
        type = types.nonEmptyStr;
        default = "eth0";
      };
      wifiIface = mkOption {
        type = types.nonEmptyStr;
        default = "wlan0";
      };
      ssid = mkOption {
        type = types.nonEmptyStr;
        example = "Bababooey Wifi";
      };
      pskSopsKey = mkOption {
        type = types.nonEmptyStr;
        description = "Sops secret key used as a template placeholder";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      pi-hole = {
        image = "docker.io/pihole/pihole:latest";
        autoStart = true;
      };
    };

    sops.secrets."${cfg.ap.pskSopsKey}".owner = "root";
    sops.templates."${cfg.ap.pskSopsKey}" = mkIf cfg.ap.enable {
      content = ''
        WIFI_IFACE=${cfg.ap.wifiIface}
        INTERNET_IFACE=${cfg.ap.internetIface}
        SSID=${cfg.ap.ssid}
        PASSPHRASE=${config.sops.placeholder."${cfg.ap.pskSopsKey}"}
      '';
      owner = "root";
    };

    systemd.services.create_ap = mkIf cfg.ap.enable {
      wantedBy = ["multi-user.target"];
      description = "Create AP Service";
      after = ["network.target"];
      restartTriggers = [apConfigFile];
      serviceConfig = {
        ExecStart = "${pkgs.linux-wifi-hotspot}/bin/create_ap --config ${apConfigFile}";
        KillSignal = "SIGINT";
        Restart = "on-failure";
      };
    };
  };
}
