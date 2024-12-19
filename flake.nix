{
  description = "mongodb packaged from the official binaries to avoid compilation";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { system = "${system}"; config.allowUnfree = true; };
      in
      rec {
        # set formatter binary for `nix fmt` command
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          cerbos = pkgs.callPackage ./packages/cerbos.nix { };
          mongodb-4_4 = pkgs.callPackage ./packages/mongodb-4_4.nix { };
          mongodb-6_0 = pkgs.callPackage ./packages/mongodb-6_0.nix { };
          dynamodb_local = pkgs.callPackage ./packages/dynamodb_local.nix { };
          adr-tools = pkgs.callPackage ./packages/adr-tools.nix { };
          multi-gitter = pkgs.callPackage ./packages/multi-gitter.nix { };
          debezium-server = pkgs.callPackage ./packages/debezium-server.nix { };
          generate-netskope-combined-cert = pkgs.callPackage ./packages/generate-netskope-combined-cert.nix { };
        };

        apps.generate-netskope-combined-cert = { type = "app"; program = "${packages.generate-netskope-combined-cert}/bin/generate"; };
      });
}
