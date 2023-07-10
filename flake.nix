{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      # TODO: only needed when nixpkgs is not up to date.
      odin-overlay = self: super: {
        odin = super.odin.overrideAttrs (old: rec {
          version = "dev-2023-07";
          src = super.fetchFromGitHub {
            owner = "odin-lang";
            repo = "Odin";
            rev = "${version}";
            sha256 = "sha256-ksCK1Qmjbg5ZgFoq0I4cjrWaCxd+UW7f1NLcSjCPMwE=";
          };

          nativeBuildInputs = with super; [ makeWrapper which ];

          LLVM_CONFIG = "${super.llvmPackages.llvm.dev}/bin/llvm-config";
          postPatch = ''
            sed -i 's/^GIT_SHA=.*$/GIT_SHA=/' build_odin.sh
            sed -i 's/LLVM-C/LLVM/' build_odin.sh
            patchShebangs build_odin.sh
          '';

          installPhase = old.installPhase + "cp -r vendor $out/bin/vendor";
        });
      };

      ols-overlay = self: super: {
        ols = super.ols.overrideAttrs (old: rec {
          version = "nightly-2023-07-08-0af33a6";
          src = super.fetchFromGitHub {
            owner = "DanielGavin";
            repo = "ols";
            rev = "0af33a64747670545eaf31d1449586ff8f08b0f9";
            sha256 = "sha256-MNl3mcVWG4Tc4xgb1bnkCZu+rZlgLh2W+sr2s2klpm4=";
          };

          installPhase = old.installPhase;
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (odin-overlay) (ols-overlay)
        ];
      };

      lib = pkgs.lib;
      in {
        devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
        pkgs.odin
        pkgs.ols
        ];
      };
    });
}
