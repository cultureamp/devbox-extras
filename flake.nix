{
  description = "mongodb packaged from the official binaries to avoid compilation";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    # this flake only works for darwin binaries (for now)
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        mongodb-4_4 = pkgs.callPackage ./packages/mongodb-4_4.nix { };
        dynamodb_local = pkgs.callPackage ./packages/dynamodb_local.nix { };
        adr-tools = pkgs.callPackage ./packages/adr-tools.nix {};
      in
      {
        packages = { inherit mongodb-4_4 dynamodb_local adr-tools; };
      });
}
