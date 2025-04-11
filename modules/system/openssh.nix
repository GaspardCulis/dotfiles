{
  _inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.openssh;
in {
  options.gasdev.openssh = {
    enable = mkEnableOption "Enable opiniated OpenSSH config";
    fail2ban = mkEnableOption "Enable opiniated fail2ban config";
    openFirewall = mkEnableOption "Open firwall for SSH connections";
    port = mkOption {
      type = types.ints.unsigned;
      description = "sshd port";
      default = 22;
    };
  };

  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        ports = [cfg.port];
        settings = {
          PasswordAuthentication = false;
        };
      };
      fail2ban = mkIf cfg.fail2ban {
        enable = true;
        maxretry = 5;
        bantime = "10m";
        bantime-increment.enable = true;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
