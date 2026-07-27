# command to convert hash to correct format
# nix-hash --to-sri --type sha256 hash-from-downloads-page

{ stdenv
, fetchzip
, jdk21
,
}:
let
  pname = "debezium-server";
  version = "3.0.0.Final";
  tarballName = "debezium-server-dist-${version}.tar.gz";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    # Google's Maven Central mirror first, falling back to Central itself.
    # See: https://cloudplatform.googleblog.com/2015/11/faster-builds-for-Java-developers-with-Maven-Central-mirror.html
    #
    # fetchurl tries these in order and stops at the first success, so the second
    # URL is only used if the mirror fails (e.g. 404 or connection error).
    urls = [
      "https://maven-central-asia.storage-download.googleapis.com/maven2/io/debezium/debezium-server-dist/${version}/${tarballName}"
      "https://repo1.maven.org/maven2/io/debezium/debezium-server-dist/${version}/${tarballName}"
    ];
    hash = "sha256-RiMBvg9925qcBL04XQ6mKfRg/OznvliSYGjo+HOFzJc=";
  };

  installPhase = ''
    runHook preInstall
    cp -R . $out
    mkdir -p $out/bin
    cat >$out/bin/run_debezium <<EOF
    #!$SHELL
    RUNNER="$out/debezium-server-dist-${version}-runner.jar"
    LIB_PATH="$out/lib/*"

    source $out/jmx/enable_jmx.sh

    exec "${jdk21}/bin/java" \
      $DEBEZIUM_OPTS $JAVA_OPTS \
      -cp \$RUNNER:"\''${CONNECTOR_CONF_PATH:-conf}":"\$LIB_PATH" io.debezium.server.Main "\$@"
    EOF

    chmod +x $out/bin/run_debezium
    runHook postInstall
  '';
}
