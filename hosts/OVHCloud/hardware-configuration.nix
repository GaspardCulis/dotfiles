{
  modulesPath,
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
  };

  # Proxy
  environment.systemPackages = with pkgs; [
    nss.tools
  ];

  services.caddy = {
    enable = true;
    package = inputs.caddy.packages.${pkgs.system}.caddy;

    globalConfig = ''
      acme_dns ovh {
        endpoint {$OVH_ENDPOINT}
        application_key {$OVH_APPLICATION_KEY}
        application_secret {$OVH_APPLICATION_SECRET}
        consumer_key {$OVH_CONSUMER_KEY}
      }
    '';
  };
  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."caddy.env".path;
    };
  };

  # Redirect to Pi4
  services.caddy.virtualHosts."pi.gasdev.fr".extraConfig = ''
    reverse_proxy http://10.8.0.31
  '';
}
