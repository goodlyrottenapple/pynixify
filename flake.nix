{
  description = "pynixify - Nix expression generator for Python projects";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
    overlay = final: prev: let
      packageOverrides = import ./nix/overlay.nix;
    in {
      python2 = prev.python2.override { inherit packageOverrides; };
      python27 = prev.python27.override { inherit packageOverrides; };
      python3 = prev.python3.override { inherit packageOverrides; };
      python35 = prev.python35.override { inherit packageOverrides; };
      python36 = prev.python36.override { inherit packageOverrides; };
      python37 = prev.python37.override { inherit packageOverrides; };
      python38 = prev.python38.override { inherit packageOverrides; };
      python39 = prev.python39.override { inherit packageOverrides; };
      python310 = prev.python310.override { inherit packageOverrides; };


      pynixify = final.python3.pkgs.toPythonApplication (final.python3.pkgs.pynixify.overridePythonAttrs
      (drv: {
        # Add system dependencies
        checkInputs = drv.checkInputs ++ [ prev.nix prev.nixfmt prev.bats ];

        postInstall = ''
          # Add nixfmt to pynixify's PATH
          wrapProgram $out/bin/pynixify --prefix PATH : "${prev.nixfmt}/bin"
        '';
      }));
    }; in


    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        }; in
      rec {
        packages.pynixify = pkgs.pynixify;
        defaultPackage = packages.pynixify;
      }
    ) // {
      inherit overlay;
    };
}
