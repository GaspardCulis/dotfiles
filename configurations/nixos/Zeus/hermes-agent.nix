{config, ...}: {
  sops.secrets."hermes-agent-env".owner = "root";

  services.hermes-agent = {
    enable = true;
    container = {
      enable = true;
      backend = "podman";
      hostUsers = ["gaspard"];
    };
    addToSystemPackages = true;
    extraDependencyGroups = ["messaging"];
    environmentFiles = [config.sops.secrets."hermes-agent-env".path];

    settings = {
      model = {
        # TODO
      };
    };
  };
}
