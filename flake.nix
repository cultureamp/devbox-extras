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

        # common parts of making derivations for flake checks
        # from: https://msfjarvis.dev/posts/writing-your-own-nix-flake-checks/
        mkCheck = nativeBuildInputs: checkPhase: pkgs.stdenvNoCC.mkDerivation {
          inherit nativeBuildInputs checkPhase;
          name = "flake-check";
          src = ./.;
          dontBuild = true;
          doCheck = true;
          installPhase = '' mkdir "$out" '';
        };
      in
      {
        # set formatter binary for `nix fmt` command
        formatter = pkgs.nixpkgs-fmt;

        checks = {
          nix-formatting = mkCheck [ pkgs.nixpkgs-fmt ] "nixpkgs-fmt --check .";
          nix-linting = mkCheck [ pkgs.statix ] "statix check";
          shellcheck = mkCheck [ pkgs.shellcheck ] "shellcheck **/*.sh";
        };

        packages = {
          mongodb-4_4 = pkgs.callPackage ./packages/mongodb-4_4.nix { };
          dynamodb_local = pkgs.callPackage ./packages/dynamodb_local.nix { };
          adr-tools = pkgs.callPackage ./packages/adr-tools.nix { };
        };
      });
}
