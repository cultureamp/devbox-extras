{ stdenv, fetchzip }:

# nixpkgs removed the `mongodb-4_4` attribute (MongoDB 4.4 reached end-of-life in
# February 2024), so there is no longer an upstream package to fall back to on Linux.
# No repo in the org consumes this package, so rather than resurrect a Linux build we
# fail loudly with a pointer to the supported alternative.
if !stdenv.hostPlatform.isDarwin then
  throw "mongodb-4_4 is only packaged for macOS here; MongoDB 4.4 is end-of-life and was removed from nixpkgs, so there is no Linux build. Use mongodb-6_0 instead."

# aarch darwin builds of this version of mongo don't exist, and compiling the x86 version is >20mins
# so provide the x86 binary version to any macOS system (this is exactly what homebrew does)
else
  stdenv.mkDerivation rec {
    pname = "mongodb-4_4";
    version = "4.4.28";

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${version}.tgz";
      hash = "sha256-0K4yL2UMfM02/rzD8Xx2TwG1Zi0bZbn7hopd4g/1NoM=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/{mongo,mongod,mongos} $out/bin/
      runHook postInstall
    '';
  }
