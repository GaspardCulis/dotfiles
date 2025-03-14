{...}: {
  services.caddy.virtualHosts."uptime.gasdev.fr".extraConfig = ''
    reverse_proxy http://127.0.0.1:3001
  '';

  virtualisation.oci-containers.containers = {
    uptime-kuma = {
      image = "docker.io/louislam/uptime-kuma:1";
      pull = "newer";
      autoStart = true;
      ports = ["127.0.0.1:3001:3001"];
      volumes = [
        "uptime-kuma:/app/data"
        # For container monitoring
        "/var/run/podman/podman.sock:/var/run/podman/podman.sock"
      ];
    };
  };
}
