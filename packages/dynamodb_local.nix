# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html
# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocalHistory.html
# command to convert hash to correct format
# nix-hash --to-sri --type sha256 hash-from-downloads-page

{ stdenv, fetchzip, makeWrapper, jdk17 }:
let
  pname = "dynamodb_local";
  version = "2.1.0";
  date = "2023-10-24";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://d1ni2b6xgvw0s0.cloudfront.net/dynamodb_local_${date}.tar.gz";
    hash = "sha256-Ucz5pO9eCH64V8KJXfbzlaNX0JQQtuqXHPcZTI9M8T8=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp DynamoDBLocal.jar $out/DynamoDBLocal.jar
    cp -r DynamoDBLocal_lib $out/DynamoDBLocal_lib
    makeWrapper ${jdk17}/bin/java \
      $out/bin/dynamodb_local --add-flags "\
      -jar $out/DynamoDBLocal.jar -sharedDb \
      -dbPath \''${DYNAMODB_DATA_PATH:-data} \
      -port \''${DYNAMODB_PORT:-8000}"
    runHook postInstall
  '';
}
