{ system, stdenv, fetchzip, mongodb-6_0 }:
# compiling mongodb is slow (10-30mins) so for macOS we pull in the binary from mongo's
# download page (same as homebrew's package does)
# see: https://www.mongodb.com/download-center/community/releases

let
  pname = "mongodb-6_0";
  version = "6.0.13";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/{mongod,mongos} $out/bin/
    runHook postInstall
  '';
  dontStrip = true; # this is a binary package, we don't need to strip debug info
in

if system == "x86_64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip;

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${version}.tgz";
      hash = "sha256-2ZyrMsXxt4AZPWbrSKcu89Uys9yCpEYDqpxqpNIcPmY=";
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip;

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-${version}.tgz";
      hash = "sha256-C0eW1CHKiF308QsPbFcS/7nLHYDmVboUynGn6VxQtA8=";
    };
  }

# we can't use binary packages on Linux as they're different per distro, so we fall back
# to the nixpkgs version
else mongodb-6_0
