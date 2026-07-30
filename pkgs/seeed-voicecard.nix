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
    rev = "2520d47cd83a0599b36f1b89539f06d52a526972";
    hash = "sha256-xHgySwvqNqLCqcnPtErJOKM7zNyJE0ug1SIEJt0TLDo=";
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
