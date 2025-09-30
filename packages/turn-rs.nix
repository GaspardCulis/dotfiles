{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
  pname = "turn-rs";
  version = "3.4.0";
  src = builtins.fetchGit {
    url = "https://github.com/mycrl/turn-rs";
    rev = "c292a8e4f255a893a75b06977eaaa38c58cabc6f";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-wnbovuxh3wc1TU8BYZEOG/8SO9bCUd0eWRC81MtAdqo=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [];
}
