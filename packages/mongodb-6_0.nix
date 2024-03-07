{ system, stdenv, fetchzip, mongodb-6_0 }:
# compiling mongodb is slow (10-30mins) so for macOS we pull in the binary from mongo's
# download page (same a homebrew's package does)
# see: https://www.mongodb.com/download-center/community/releases

let
  pname = "mongodb-6_0";
  version = "6.0.14";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/{mongod,mongos} $out/bin/
    runHook postInstall
  '';
in

if system == "x86_64-darwin" then
  stdenv.mkDerivation
  rec {
    inherit pname version installPhase;

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${version}.tgz";
      hash = "sha256-ZW8GMRr5wXGOyBy12Dq5CnTxpqda/csfszuoYZ1pRtM=";
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase;

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-${version}.tgz";
      hash = "sha256-F6etuVeRMGZGyfQKdhrTy6LvFNHCIgrZDOzxOw/jCus=";
    };
  }

# we can't use binary packages on Linux as they're different per distro, so we fall back
# to the nixpkgs version
else mongodb-6_0
