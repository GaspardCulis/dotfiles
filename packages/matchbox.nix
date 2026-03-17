{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "matchbox_server";
  version = "0.14.0";
  src = pkgs.fetchFromGitHub {
    owner = "johanhelsing";
    repo = "matchbox";
    rev = "v0.14.0";
    hash = "sha256-NlmGUXroKh+SXvXSecjNka0t4SaxWbUL8XFXkkXKK+U=";
  };
  cargoHash = "sha256-YeCncI51oO2r2gphdtQ3GRulu7x2XeXiSrcWxn3J+dE=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [];
}
