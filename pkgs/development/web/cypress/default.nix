{ alsa-lib
, autoPatchelfHook
, callPackage
, fetchzip
, gtk2
, gtk3
, lib
, mesa
, nss
, stdenv
, udev
, unzip
, wrapGAppsHook
, xorg
}:

let
  availableBinaries = {
    x86_64-linux = {
      platform = "linux-x64";
      checksum = "sha256-26mkizwkF0qPX2+0rkjep28ZuNlLGPljCvVO73t34Lk=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      checksum = "sha256-gcf/MJ5aNUPoH6qz0n9vjviTec1rcxB0UzF+++6bUTs=";
    };
  };
  inherit (stdenv.hostPlatform) system;
  binary = availableBinaries.${system} or (throw "cypress: No binaries available for system ${system}");
  inherit (binary) platform checksum;
in stdenv.mkDerivation rec {
  pname = "cypress";
  version = "10.10.0";

  src = fetchzip {
    url = "https://cdn.cypress.io/desktop/${version}/${platform}/cypress.zip";
    sha256 = checksum;
  };

  # don't remove runtime deps
  dontPatchELF = true;

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook unzip ];

  buildInputs = with xorg; [
    libXScrnSaver
    libXdamage
    libXtst
    libxshmfence
  ] ++ [
    nss
    gtk2
    alsa-lib
    gtk3
    mesa # for libgbm
  ];

  runtimeDependencies = [ (lib.getLib udev) ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/cypress
    cp -vr * $out/opt/cypress/
    # Let's create the file binary_state ourselves to make the npm package happy on initial verification.
    # Cypress now verifies version by reading bin/resources/app/package.json
    mkdir -p $out/bin/resources/app
    printf '{"version":"%b"}' $version > $out/bin/resources/app/package.json
    # Cypress now looks for binary_state.json in bin
    echo '{"verified": true}' > $out/binary_state.json
    ln -s $out/opt/cypress/Cypress $out/bin/Cypress

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;

    tests = {
      example = callPackage ./cypress-example-kitchensink { };
    };
  };

  meta = with lib; {
    description = "Fast, easy and reliable testing for anything that runs in a browser";
    homepage = "https://www.cypress.io";
    mainProgram = "Cypress";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = lib.attrNames availableBinaries;
    maintainers = with maintainers; [ tweber mmahut Crafter ];
  };
}
