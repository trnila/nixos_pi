{
  lib,
  pkgs,
  python3Packages,
  fetchFromGitHub,
}:

let
  pythonPackages = python3Packages.overrideScope (
    pyFinal: pyPrev: {
      pymicro-wakeword = pyFinal.buildPythonPackage rec {
        pname = "pymicro_wakeword";
        version = "2.4.1";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-QyuKLhpvuJ2Rad3b2luognr2lH56t6DrGp2y7399Y14=";
        };

        pyproject = true;

        postPatch = ''
          substituteInPlace pymicro_wakeword/microwakeword.py \
            --replace-fail "_MODULE_LIB_DIR = _DIR / \"lib\"" "_MODULE_LIB_DIR = Path(\"${pkgs.tensorflow-lite}/lib\")"
        '';

        buildInputs = [
          pkgs.tensorflow-lite
        ];

        build-system = with pyFinal; [
          setuptools
          wheel
        ];

        dependencies = with pyFinal; [
          pymicro-features
        ];
      };

      pymicro-features = pyFinal.buildPythonPackage rec {
        pname = "pymicro_features";
        version = "2.0.2";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-DQvteEPseLbO2C0aLc3etP5d9hs6+AooHQhoyOJ5xyc=";
        };

        pyproject = true;

        build-system = with pyFinal; [
          setuptools
          wheel
        ];

        dependencies = with pyFinal; [
          numpy
        ];
      };

      python-mpv = pyFinal.buildPythonPackage rec {
        pname = "python_mpv";
        version = "1.0.8";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-AX+jWdoFnIMalMQZCDSRkD5tL3yBuYQcM8GWyr9LP+M=";
        };

        pyproject = true;

        build-system = with pyFinal; [
          setuptools
        ];
      };

      websockets = pyFinal.buildPythonPackage rec {
        pname = "websockets";
        version = "12.0";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-gd+cvLtsJg3h4AfljAEb/r4tr8hDUQewU385PdOMixs=";
        };

        pyproject = true;

        build-system = with pyFinal; [
          setuptools
        ];
      };
    }
  );
in

pythonPackages.buildPythonApplication rec {
  pname = "linux-voice-assistant";
  version = "1.1.13";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "linux-voice-assistant";
    rev = "v${version}";
    hash = "sha256-1M1INDXhJJvkDhZD96yMe7xsuxmHELs6sMQ9fdd18Q0=";
  };

  buildInputs = [
    pkgs.mpv
    pkgs.which
  ];

  dependencies = with pythonPackages; [
    aioesphomeapi
    netifaces2
    soundcard
    numpy
    pymicro-wakeword
    pyopen-wakeword
    mpv
    zeroconf
    getmac
    types-protobuf
    websockets
    webrtc-noise-gain
  ];

  build-system = with pythonPackages; [
    setuptools
    setuptools-scm
    wheel
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "python-mpv" "mpv"
  '';

  postInstall = ''
    mkdir -p $out/${pythonPackages.python.sitePackages}
    cp -r ./wakewords $out/${pythonPackages.python.sitePackages}/wakewords
    cp -r ./sounds $out/${pythonPackages.python.sitePackages}/sounds
  '';

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${pkgs.mpv}/lib"
    "--prefix PATH : ${pkgs.which}/bin"
  ];
}
