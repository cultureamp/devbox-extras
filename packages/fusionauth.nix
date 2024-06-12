{ lib, stdenv, fetchzip}:

 stdenv.mkDerivation rec {
   pname = "fusion-auth";
   version = "1.5.0";

   src = fetchzip {
     url = "https://files.fusionauth.io/products/fusionauth/${version}/fusionauth-app-${version}.zip";
     hash = "sha256-M5lPZGa9qN8fdpWRJQlzc0S7ELimUV7cYlBtqrhQz1Y=";
     stripRoot = false;
   };

   fusionauthscript = builtins.toFile "fusionauthrunscript" (builtins.readFile ./src/fusionauth);

   installPhase = ''
    mkdir -p $out/config $out
    cp -r $src/config $out
    cp -r $src/fusionauth-app $out
    mkdir -p $out/bin
    cp ${fusionauthscript} $out/bin/fusionauth
    chmod +x $out/bin/fusionauth
    '';

   meta = with lib; {
     description = "A script to start the FusionAuth app service";
     homepage = "https://example.com";
     license = licenses.mit;
     maintainers = with maintainers; [ your-maintainer ];
   };
 }
