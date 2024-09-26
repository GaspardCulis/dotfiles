{config, ...}: {
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../../secrets/OVHCloud.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets."caddy/ovh_endpoint".owner = "caddy";
  sops.secrets."caddy/ovh_application_key".owner = "caddy";
  sops.secrets."caddy/ovh_application_secret".owner = "caddy";
  sops.secrets."caddy/ovh_consumer_key".owner = "caddy";

  sops.templates."caddy.env" = {
    content = ''
      OVH_ENDPOINT=${config.sops.placeholder."caddy/ovh_endpoint"}
      OVH_APPLICATION_KEY=${config.sops.placeholder."caddy/ovh_application_key"}
      OVH_APPLICATION_SECRET=${config.sops.placeholder."caddy/ovh_application_secret"}
      OVH_CONSUMER_KEY=${config.sops.placeholder."caddy/ovh_consumer_key"}
    '';
    owner = "caddy";
  };
}
