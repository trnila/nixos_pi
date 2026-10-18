final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pythonFinal: pythonPrev: {
      scikit-learn = pythonPrev.scikit-learn.overridePythonAttrs (_: {
        doCheck = false;
      });
      pyopenjtalk-plus = pythonPrev.pyopenjtalk-plus.overridePythonAttrs (_: {
        disabledTestPaths =
          pythonPrev.disabledTestPaths or [
            "tests/test_frontend.py"
          ];
      });
    })
  ];
}
