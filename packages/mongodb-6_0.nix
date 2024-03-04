{ stdenv, fetchzip, mongodb-6_0 }:

# the linux builds of mongo work fine, so default to the standard nixpkgs version if we're on linux
if !stdenv.isDarwin then
  mongodb-6_0

# aarch darwin builds of this version of mongo don't exist, and compiling the x86 version is >20mins
# so provide the x86 binary version to any macOS system (this is exactly what homebrew does)
else
  stdenv.mkDerivation rec {
    pname = "mongodb-6_0";
    version = "6.0.13";

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${version}.tgz";
      hash = "sha256-2ZyrMsXxt4AZPWbrSKcu89Uys9yCpEYDqpxqpNIcPmY=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/{mongod,mongos} $out/bin/
      runHook postInstall
    '';
  }
