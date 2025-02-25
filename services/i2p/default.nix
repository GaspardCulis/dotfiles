{...}: {
  services.caddy.virtualHosts."console.i2p.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7657
  '';

  services.caddy.virtualHosts."proxy.i2p.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:7657
  '';

  virtualisation.oci-containers.containers = {
    i2p = {
      image = "docker.io/geti2p/i2p";
      pull = "newer";
      autoStart = true;
      environment = {
        JVM_XMX = "256m";
      };
      ports = [
        "4444:4444"
        "6668:6668"
        "7657:7657"
        "54321:12345"
        "54321:12345/udp"
      ];
      volumes = ["i2phome:/i2p/.i2p" "i2ptorrents:/i2psnark"];
    };
  };
}
