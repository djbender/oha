{
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, fenix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        toolchain = fenix.packages.${system}.minimal.toolchain;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default =
          (pkgs.makeRustPlatform {
            cargo = toolchain;
            rustc = toolchain;
          }).buildRustPackage {
            pname = "oha";
            version = "1.4.3";

            nativeBuildInputs = with pkgs; [
              cmake
            ];

            buildInputs = with pkgs; [] ++ lib.optionals stdenv.isDarwin [
              darwin.apple_sdk.frameworks.Foundation
            ];

            checkFlags = [
              "--skip=test_google"
            ];

            src = ./.;

            cargoLock.lockFile = ./Cargo.lock;
          };
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            toolchain
            cmake
            libiconv
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Foundation
          ];
        };
    }
  );
}
