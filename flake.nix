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
        mkCheck = { name, nativeBuildInputs, checkPhase }: pkgs.stdenvNoCC.mkDerivation {
          inherit name nativeBuildInputs checkPhase;
          src = ./.;
          dontBuild = true;
          doCheck = true;
          installPhase = ''
            mkdir "$out"
          '';
        };
      in
      {
        # set formatter binary for `nix fmt` command
        formatter = pkgs.nixpkgs-fmt;

        checks = {
          nix-formatting = mkCheck {
            name = "nix-formatting";
            nativeBuildInputs = [ pkgs.nixpkgs-fmt ];
            checkPhase = "nixpkgs-fmt --check .";
          };
          nix-linting = mkCheck {
            name = "nix-linting";
            nativeBuildInputs = [ pkgs.statix ];
            checkPhase = "statix check";
          };
          shell-linting = mkCheck {
            name = "shell-linting";
            nativeBuildInputs = [ pkgs.shellcheck ];
            checkPhase = "shellcheck **/*.{sh,bash,bats}";
          };
          shell-formatting = mkCheck {
            name = "shell-formatting";
            nativeBuildInputs = [ pkgs.shfmt ];
            checkPhase = "shfmt --write **/*.{sh,bash,bats}";
          };
        };

        packages = {
          mongodb-4_4 = pkgs.callPackage ./packages/mongodb-4_4.nix { };
          dynamodb_local = pkgs.callPackage ./packages/dynamodb_local.nix { };
          adr-tools = pkgs.callPackage ./packages/adr-tools.nix { };
        };
      });
}
