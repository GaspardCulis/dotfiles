{
  config,
  pkgs,
  lib,
  ...
}: {
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };
  # Network & Bluetooth
  networking.networkmanager.enable = true;

  # Wireguard
  networking.firewall.checkReversePath = "loose";
  networking.firewall = {
    allowedUDPPorts = [51820];
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.8.0.31/32"];
      listenPort = 51820; # Should match firewall allowedUDPPorts
      privateKeyFile = config.sops.secrets."wireguard/private_key".path;

      peers = [
        {
          publicKey = "KLULII6VEUWMhyIba6oxxHdZsVP3TMVlNY1Vz49q7jg=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "vpn.gasdev.fr:993";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
