# get updated hashs with:
# `nix-hash --to-sri --type sha256 $(nix-prefetch-url --unpack https://github.com/lindell/multi-gitter/releases/download/v${version}/multi-gitter_${version}_Darwin_${arch}.tar.gz)`

{ system, lib, stdenv, fetchzip }:
let
  inherit (lib) licenses;
  pname = "multi-gitter-${version}";
  version = "0.57.1";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp multi-gitter $out/bin/multi-gitter
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
      url = "https://github.com/lindell/multi-gitter/releases/download/v${version}/multi-gitter_${version}_Darwin_x86_64.tar.gz";
      hash = "sha256-O9jt6HatnuivMx8Lcdc5Qd5Y4nM9ke7ktQQYy3PadRA=";
      stripRoot = false;
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip meta;

    src = fetchzip {
      url = "https://github.com/lindell/multi-gitter/releases/download/v${version}/multi-gitter_${version}_Darwin_ARM64.tar.gz";
      hash = "sha256-o6GxO8voV1qpXm+RHNv/WKmA+sVSbpUVINtk2WptsZY=";
      stripRoot = false;
    };
  }

else
  abort "unsupported system"
