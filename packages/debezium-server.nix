# command to convert hash to correct format
# nix-hash --to-sri --type sha256 hash-from-downloads-page

{
  stdenv,
  fetchzip,
  makeWrapper,
  jdk,
}: let
  pname = "debezium-server";
  version = "2.7.1.Final";
  tarballName = "debezium-server-dist-${version}.tar.gz";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchzip {
      url = "https://repo1.maven.org/maven2/io/debezium/debezium-server-dist/${version}/${tarballName}";
      hash = "sha256-y7elU/9zBjGSpBFwAXHvhZvLb0QvvBazwDNP9yBQdJw=";
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      cp -R . $out
      RUNNER=$(ls $out/debezium-server-*runner.jar)
      PATH_SEP=":"
      LIB_PATH="$out/lib/*"
      makeWrapper ${jdk}/bin/java \
        $out/bin/run_debezium --add-flags "\
        \''$DEBEZIUM_OPTS \''$JAVA_OPTS -cp \
        $RUNNER$PATH_SEP\"\''${CONNECTOR_CONF_PATH:-conf}\"$PATH_SEP$LIB_PATH io.debezium.server.Main"
      runHook postInstall
    '';
  }