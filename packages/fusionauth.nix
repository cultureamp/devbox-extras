{ lib, stdenv, fetchzip}:

 stdenv.mkDerivation rec {
   pname = "fusion-auth";
   version = "1.5.0";

   src = fetchzip {
     url = "https://files.fusionauth.io/products/fusionauth/${version}/fusionauth-app-${version}.zip";
     hash = "sha256-M5lPZGa9qN8fdpWRJQlzc0S7ELimUV7cYlBtqrhQz1Y=";
     stripRoot = false;
   };

   # This is referencing jre8 in nix store, how do I:
   # - make it a dependency
   # - get the path to the jre8 in the nix store dynamically in the patch
   patches = [ ./patches/fusionauth/setenv.patch ./patches/fusionauth/startup.patch ];

   installPhase = ''
   mkdir -p $out/bin $out/config $out/fusionauth-app
   cp -r $src/* $out
   '';

   meta = with lib; {
     description = "A script to start the FusionAuth app service";
     homepage = "https://example.com";
     license = licenses.mit;
     maintainers = with maintainers; [ your-maintainer ];
   };
 }
