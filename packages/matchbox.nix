{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "matchbox_server";
  version = "0.11.0";
  src = pkgs.fetchFromGitHub {
    owner = "johanhelsing";
    repo = "matchbox";
    rev = "v0.11.0";
    hash = "sha256-fF6SeZhfOkyK1hAWxdcXjf6P6pVJWLlkIUtyGxVrm94=";
  };
  cargoHash = "sha256-ELA9+wTFYxiuG/QLb0oxN5KfVSalWKmKEvzRlxNHQnw=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [];
}
