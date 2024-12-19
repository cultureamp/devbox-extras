{ system, stdenv, fetchzip }:

let
  pname = "cerbos";
  version = "0.40.0";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ls -lah
    cp {cerbos,cerbosctl} $out/bin
    runHook postInstall
  '';
  dontStrip = true; # this is a binary package, we don't need to strip debug info
in

if system == "x86_64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip;

    src = fetchzip {
      url = "https://github.com/cerbos/cerbos/releases/download/v${version}/${pname}_${version}_Darwin_x86_64.tar.gz";
      hash = "sha256-bOB11SSWy5Y7NhP6OpBAlp4yee8ET+8LcFNGkWGwtsM=";
      stripRoot = false;
    };
  }

else if system == "aarch64-darwin" then
  stdenv.mkDerivation
  {
    inherit pname version installPhase dontStrip;

    src = fetchzip {
      url = "https://github.com/cerbos/cerbos/releases/download/v${version}/${pname}_${version}_Darwin_arm64.tar.gz";
      hash = "sha256-K+8qtdayIUWgdVfoWVwKfJ+NWsY5IHuB18Ur1Kfs+z8=";
      stripRoot = false;
    };
  }
else
  throw "The flake does not yet support this system, please contact #team_delivery_engineering on slack. Unsupported system: ${system}"
