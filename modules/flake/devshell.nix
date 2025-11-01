{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        git
        nil
        sops
        home-manager
        deploy-rs
      ];
    };
  };
}
