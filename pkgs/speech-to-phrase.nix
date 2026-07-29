{
  lib,
  pkgs,
  python3,
  python3Packages,
  fetchFromGitHub,
}:

let
  pythonPackages = python3Packages.overrideScope (
    pyFinal: pyPrev: {
      regex = pyFinal.buildPythonPackage rec {
        pname = "regex";
        version = "2024.11.6";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-erFZsGPFKgMzyITkZ5+NeoURLuMHj+PZAEst2HVYVRk=";
        };

        pyproject = true;

        build-system = with pyFinal; [
          setuptools
        ];
      };

      ruamel-yaml = pyFinal.buildPythonPackage rec {
        pname = "ruamel.yaml";
        version = "0.18.14";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-cie3aq7DZN8Vk2cw7799crMMC3mx1Xi7uOPcstgfUrc=";
        };

        pyproject = true;
        build-system = with pyFinal; [
          setuptools
        ];
      };

      pysilero-vad = pyFinal.buildPythonPackage rec {
        pname = "pysilero_vad";
        version = "2.1.1";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-7+h8EYGLIgzfFz2h9NVOFmnpXLdEYazMTgJZi/ZAwSA=";
        };

        dependencies = with pyFinal; [
          onnxruntime
          numpy
        ];

        pyproject = true;
        build-system = with pyFinal; [
          setuptools
        ];
      };
    }
  );
in

pythonPackages.buildPythonApplication rec {
  pname = "speech-to-phrase";
  version = "1.4.3";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "speech-to-phrase";
    rev = "b4ecef9519e84fefd5dc35c0384c50efa13a0bad";
    hash = "sha256-9t+dHz2ROO6kEOunbTdelCDOI9Fs1+XdwwJgGZJUCYo=";
  };

  buildInputs = [

  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "wyoming==1.5.4" "wyoming"
  '';

  dependencies = with pythonPackages; [
    hassil
    pyyaml
    unicode-rbnf
    regex
    wyoming
    aiohttp
    pysilero-vad
    pyring-buffer
    ruamel-yaml
  ];

  build-system = with pythonPackages; [
    setuptools
    wheel
  ];

  postInstall = ''
    makeWrapper ${python3.withPackages (_: dependencies)}/bin/python \
      $out/bin/speech-to-phrase \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --add-flags "-m speech_to_phrase"
  '';
}
