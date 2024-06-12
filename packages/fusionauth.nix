{ lib, stdenv, fetchzip}:

 stdenv.mkDerivation rec {
   pname = "fusion-auth";
   version = "1.5.0";

   src = fetchzip {
     url = "https://files.fusionauth.io/products/fusionauth/${version}/fusionauth-app-${version}.zip";
     hash = "sha256-M5lPZGa9qN8fdpWRJQlzc0S7ELimUV7cYlBtqrhQz1Y=";
     stripRoot = false;
   };

   installPhase = ''
    cp -r $src $out
    rm -rf $out/bin
    echo "${builtins.readFile ./src/fusionauth}" > $out/bin/fusionauth
    chmod +x $out/bin/fusionauth
    '';

   meta = with lib; {
     description = "A script to start the FusionAuth app service";
     homepage = "https://example.com";
     license = licenses.mit;
     maintainers = with maintainers; [ your-maintainer ];
   };
 }
