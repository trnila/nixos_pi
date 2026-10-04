final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pythonFinal: pythonPrev: {
      scikit-learn = pythonPrev.scikit-learn.overridePythonAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
