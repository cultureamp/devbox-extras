{ stdenv, fetchurl, makeWrapper, jre, graphviz, lib }:
let
  pname = "structurizr-lite";
  version = "v2024.12.07";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/structurizr/lite/releases/download/${version}/structurizr-lite.war";
    hash = "sha256-0/MPL6fN8L4oio8xEeCmBuLuUU/uNr0j/WN70jJ5Tao=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp $src $out/lib/structurizr-lite.war

    makeWrapper ${jre}/bin/java $out/bin/structurizr \
        --prefix PATH : ${lib.makeBinPath [ graphviz ]} \
        --add-flags "-Djdk.util.jar.enableMultiRelease=false" \
        --add-flags "-Dserver.port=\''${PORT:-7222}" \
        --add-flags "-jar $out/lib/structurizr-lite.war"

    runHook postInstall
  '';
}
