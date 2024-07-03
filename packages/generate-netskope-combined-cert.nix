{ cacert, writeShellScriptBin }:
let
  cacertCombined = cacert.override {
    extraCertificateStrings = [ (builtins.readFile ../certs/nscacert.pem) ];
  };
in
writeShellScriptBin "generate" "cat ${cacertCombined}/etc/ssl/certs/ca-bundle.crt > ./certs/nscacert_combined.pem"
