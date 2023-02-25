{ lib
, betamax
, betamax-matchers
, betamax-serializers
, buildPythonPackage
, fetchFromGitHub
, mock
, prawcore
, pytestCheckHook
, pythonOlder
, requests-toolbelt
, update_checker
, websocket-client
}:

buildPythonPackage rec {
  pname = "praw";
  version = "7.7.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "praw-dev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-reJW1M1yDSQ1SvZJeOc0jwHj6ydl1AmMl5VZqRHxXZA=";
  };

  propagatedBuildInputs = [
    mock
    prawcore
    update_checker
    websocket-client
  ];

  nativeCheckInputs = [
    betamax
    betamax-serializers
    betamax-matchers
    pytestCheckHook
    requests-toolbelt
  ];

  pythonImportsCheck = [
    "praw"
  ];

  meta = with lib; {
    description = "Python Reddit API wrapper";
    homepage = "https://praw.readthedocs.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ fab ];
  };
}
