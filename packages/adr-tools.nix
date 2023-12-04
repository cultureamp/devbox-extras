{ stdenv, fetchFromGitHub, lib }:

stdenv.mkDerivation rec {
  pname = "adr-tools";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "npryce";
    repo = "adr-tools";
    rev = version;
    sha256 = lib.fakeSha256;
  };

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';
}
