{
  description = "mongodb packaged from the official binaries to avoid compilation";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    # this flake only works for darwin binaries (for now)
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        mongodb-4_4 = pkgs.callPackage ./mongodb-4_4.nix { };
      in
      {
        packages = { inherit mongodb-4_4; };
      });
}
