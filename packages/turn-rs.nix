{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "turn-rs";
  version = "4.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "mycrl";
    repo = "turn-rs";
    url = "https://github.com/mycrl/turn-rs";
    rev = "v4.0.0";
    hash = "sha256-HYrFnwxj4BRk2PGK52il5Bh5hxvWHJNQ/5Y0u5FSTwY=";
  };
  cargoHash = "sha256-q1kq2ISzKZfJfKTRkMrVMQqngAqG2INfej9lGoll5c0=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [];
}
