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
          version = "9453b2387b2cc7c473547997703c305e7982f5e4"; # 2023-08-01
          src = super.fetchFromGitHub {
            owner = "odin-lang";
            repo = "Odin";
            rev = "${version}";
            sha256 = "pmgrauhB5/JWBkwrAm7tCml9IYQhXyGXsNVDKTntA0M=";
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
          version = "nightly-2023-07-29-a010fd2";
          src = super.fetchFromGitHub {
            owner = "DanielGavin";
            repo = "ols";
            rev = "a010fd2c8f9c3b3bd4cec75022c50aac94c0cb02";
            sha256 = "mAAgbc2SzC/scxDSTyN9CtLUaYI9kNvMRvKaXT9P20s=";
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

        # for ols
        ODIN_ROOT = "${pkgs.odin}/share";
      };
    });
}
