# package.nix
{ lib, stdenv, fetchurl, makeWrapper, jdk25, ffmpeg }:

let
  version = "3.2.2";

  jar = fetchurl {
    url = "https://github.com/grimmory-tools/grimmory/releases/download/v${version}/grimmory.jar";
    sha256 = "sha256-D37a6MxNDdtdjzJmQBwmaCBgqM/G+wBWdPnFN2tSj/g=";
  };

  kepubifyVersion = "4.0.4";
  kepubify = fetchurl {
    url = "https://github.com/pgaskin/kepubify/releases/download/v${kepubifyVersion}/kepubify-linux-${
      if stdenv.hostPlatform.isAarch64 then "arm64" else "64bit"
    }";
    sha256 = if stdenv.hostPlatform.isAarch64
      then "5a15b8f6f6a96216c69330601bca29638cfee50f7bf48712795cff88ae2d03a3"
      else "37d7628d26c5c906f607f24b36f781f306075e7073a6fe7820a751bb60431fc5";
  };
in
stdenv.mkDerivation {
  pname = "grimmory";
  inherit version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/java $out/libexec
    cp ${jar} $out/share/java/grimmory.jar
    install -m755 ${kepubify} $out/libexec/kepubify

    makeWrapper ${jdk25}/bin/java $out/bin/grimmory \
      --add-flags "-jar $out/share/java/grimmory.jar" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
      --set KEPUBIFY_PATH $out/libexec/kepubify
  '';

  meta = with lib; {
    description = "Self-hosted digital library, fork of Booklore";
    homepage = "https://github.com/grimmory-tools/grimmory";
    license = licenses.agpl3Plus;
    mainProgram = "grimmory";
    platforms = platforms.linux;
  };
}
