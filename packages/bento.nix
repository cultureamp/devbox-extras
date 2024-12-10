{ system, lib, stdenv, fetchzip }:
let
  inherit (lib) licenses;
  pname = "bento-${version}";
  version = "1.4.0";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bento $out/bin/bento
    runHook postInstall
  '';
  dontStrip = true;
  meta = with lib; {
    description = "A tool to manage multiple git repositories";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
in

if system == "x86_64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip meta;

    src = fetchzip {
      url = "https://github.com/warpstreamlabs/bento/releases/download/v${version}/bento_${version}_darwin_amd64.tar.gz";
      hash = "sha256-R+SC8u2Nje6tDCb5jzxQ+o/wHe9NFYDTBr05tuU+DUY=";
      stripRoot = false;
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip meta;

    src = fetchzip {
      url = "https://github.com/warpstreamlabs/bento/releases/download/v${version}/bento_${version}_darwin_arm64.tar.gz";
      hash = "sha256-Db1u1MmPRLLcH8q4sGqr29UqJqNJf7XTNAoxU023K60=";
      stripRoot = false;
    };
  }

else
  abort "unsupported system"
