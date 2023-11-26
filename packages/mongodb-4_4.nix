{ stdenv, fetchzip, mongodb-4_4 }:

# the linux builds of mongo work fine, so default to the standard nixpkgs version if we're on linux
if !stdenv.isDarwin then
  mongodb-4_4

# aarch darwin builds of this version of mongo don't exist, and compiling the x86 version is >20mins
# so provide the x86 binary version to any macOS system (this is exactly what homebrew does)
else
  stdenv.mkDerivation rec {
    pname = "mongodb-4_4";
    version = "4.4.25";

    src = fetchzip {
      url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${version}.tgz";
      hash = "sha256-zZtpcSFhzxdC39pJY4F+yaoc4RXfcP+e2lnw8wi/avk=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp bin/{mongo,mongod,mongos} $out/bin/
      runHook postInstall
    '';
  }
