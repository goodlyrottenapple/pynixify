{
  description = "pynixify - Nix expression generator for Python projects";
  inputs = { flake-utils.url = "github:numtide/flake-utils"; };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev:
        prev.lib.genAttrs [
          "python2"
          "python27"
          "python3"
          "python35"
          "python36"
          "python37"
          "python38"
          "python39"
          "python310"
        ] (python:
          prev.${python}.override {
            packageOverrides = import ./nix/overlay.nix;
          }) // {
            pynixify = final.python3.pkgs.toPythonApplication
              (final.python3.pkgs.pynixify.overridePythonAttrs (drv: {
                # Add system dependencies
                checkInputs = drv.checkInputs
                  ++ [ prev.nix prev.nixfmt prev.bats ];

                postInstall = ''
                  # Add nixfmt to pynixify's PATH
                  wrapProgram $out/bin/pynixify --prefix PATH : "${prev.nixfmt}/bin"
                '';
              }));
          };

    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in rec {
        packages.pynixify = pkgs.pynixify;
        defaultPackage = packages.pynixify;
      }) // {
        inherit overlay;
      };
}
