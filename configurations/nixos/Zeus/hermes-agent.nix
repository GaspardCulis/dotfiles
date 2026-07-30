{config, ...}: {
  sops.secrets."hermes-agent-env".owner = "root";

  containers.hermes-agent = {
    flake = "github:MarcusLeFils/nixos-config/main";
    autoStart = true;

    bindMounts = {
      "${config.sops.secrets."hermes-agent-env".path}".isReadOnly = true;

      "/var/lib/hermes".isReadOnly = false;
    };
  };
}
