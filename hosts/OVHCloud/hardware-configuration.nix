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
    virtualHosts."siuu.gasdev.fr".extraConfig = ''
      respond "Hello, world!"
    '';
  };
  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."caddy.env".path;
    };
  };
}
