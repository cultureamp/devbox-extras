{ stdenv, fetchzip }:
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
