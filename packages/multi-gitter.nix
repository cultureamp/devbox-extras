{ system, lib, stdenv, fetchzip }:
let
  inherit (lib) licenses;
  pname = "multi-gitter-${version}";
  version = "0.52.0";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/multi-gitter $out/bin/multi-gitter
    runHook postInstall
  '';
  dontStrip = true;
  meta = with lib; {
    description = "A tool to manage multiple git repositories";
    license = licenses.asl20;
    platforms = platforms.darwin;
  };
in

if system == "x86_64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip meta;

    src = fetchzip {
      url = "https://github.com/lindell/multi-gitter/releases/download/v${version}/multi-gitter_${version}_Darwin_ARM64.tar.gz";
      hash = "sha256-DkqcQrz0PLjb21skaks6BrdLyxEymhmkdH8vFNrGJqQ=";
      stripRoot = false;
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip meta;

    src = fetchzip {
      url = "https://github.com/lindell/multi-gitter/releases/download/v${version}/multi-gitter_${version}_Darwin_x86_64.tar.gz";
      hash = "sha256-k+vngTWJZ/ySiDWPVWBZdoGnaKyUMffY2au6WGYClLQ=";
      stripRoot = false;
    };
  }

else
  abort "unsupported system"
