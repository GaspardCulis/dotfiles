{pkgs, ...}: {
  sops.secrets."wireguard/private_key".owner = "root";

  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    allowedUDPPorts = [993];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Use AmneziaWG implementation for DPI obfuscation
      type = "amneziawg";

      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = ["10.8.0.1/24"];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 993;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens3 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens3 -j MASQUERADE
      '';

      privateKeyFile = "/run/secrets/wireguard/private_key";

      peers = [
        {
          # Pixel
          publicKey = "xMO5xTvBXtikri0WS9wpzGvSWITjkQV5oUOYwFjqB0g=";
          allowedIPs = ["10.8.0.69/32"];
        }
        {
          # Zephyrus
          publicKey = "42Vj5VG4bJpOUE7j5UW28IFSmPlV+X3tIA9ne55W0Fo=";
          allowedIPs = ["10.8.0.42/32"];
        }
        {
          # Family desktop
          publicKey = "cpBhnLD4u5brDZsc2uqXVlelApCIXFdRnfJXJU1WDmM=";
          allowedIPs = ["10.8.0.11/32"];
        }
        {
          # pi4
          publicKey = "F9AkCI0FGkrFhCq+SvCT1F2RG2ApNUy+SeIj1+VPtXI=";
          allowedIPs = ["10.8.0.31/32"];
        }
        {
          # Leito
          publicKey = "L7FNP+XjELr4AYW3jeZNKNS25ukJ3rMvIz3YYSYd61Y=";
          allowedIPs = ["10.8.0.111/32"];
        }
      ];
    };
  };
}
