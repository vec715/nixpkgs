{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, argparse-dataclass
, ConfigArgParse
}:

buildPythonPackage rec {
  pname = "snakemake-interface-common";
  version = "1.15.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-Rf2eMkRvkTCR2swB53ekjv8U8DzTPgjhIkBVrn6gTTI=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    argparse-dataclass
    ConfigArgParse
  ];

  pythonImportsCheck = [ "snakemake_interface_common" ];

  meta = with lib; {
    description = "Common functions and classes for Snakemake and its plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-common";
    license = licenses.mit;
    maintainers = with maintainers; [ veprbl ];
  };
}
