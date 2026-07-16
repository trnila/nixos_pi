{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation {
  pname = "seeed-voicecard";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "trnila";
    repo = "seeed-voicecard";
    rev = "v6.15";
    hash = "sha256-RnmmGw0lacL3uSX2TIXQLJSbdyPU2OU421OfulIfWBc=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/extra/
  '';
}
