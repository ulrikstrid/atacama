{
  nixConfig = {
    extra-substituters = "https://ocaml.nix-cache.com";
    extra-trusted-public-keys = "ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY=";
  };

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.follows = "nixpkgs/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        kqueue =  with pkgs.ocaml-ng.ocamlPackages_5_1; buildDunePackage rec {
          pname = "kqueue";
          version = "0.3.0";

          minimalOCamlVersion = "4.12";

          src = pkgs.fetchurl {
            url = "https://github.com/anuragsoni/kqueue-ml/releases/download/${version}/kqueue-${version}.tbz";
            hash = "sha256-MKRCyN6q9euTEgHIhldGGH8FwuLblWYNG+SiCMWBP6Y=";
          };

          buildInputs = [
            dune-configurator
            ppx_optcomp
          ];

          checkInputs = [
            ppx_expect
          ];

          doCheck = true;
        };

        poll = with pkgs.ocaml-ng.ocamlPackages_5_1; buildDunePackage rec {
          pname = "poll";
          version = "0.3.1";

          minimalOCamlVersion = "4.13";

          src = pkgs.fetchurl {
            url = "https://github.com/anuragsoni/poll/releases/download/${version}/poll-${version}.tbz";
            hash = "sha256-IX6SivK/IMQaGgMgWiIsNgUSMHP6z1E/TSB0miaQ8pw=";
          };

          buildInputs = [
            dune-configurator
            ppx_optcomp
          ];

          propagatedBuildInputs = [
            kqueue
          ];

          checkInputs = [
            ppx_expect
          ];

          doCheck = true;
        };

        telemetry = with  pkgs.ocaml-ng.ocamlPackages_5_1; buildDunePackage rec {
          version = "0.0.1";

          pname = "telemetry";

          src = pkgs.fetchFromGitHub {
            owner = "leostera";
            repo = pname;
            rev = version;
            sha256 = "sha256-x+0GPqOiUrY4I9tifFlPCRqpF+AsJ9s9Ohpf2ynF6Y0=";
          };

          doCheck = false;
        };

        riot = with  pkgs.ocaml-ng.ocamlPackages_5_1; buildDunePackage rec {
          version = "0.0.7";

          pname = "riot";

          src = pkgs.fetchFromGitHub {
            owner = "leostera";
            repo = pname;
            rev = version;
            sha256 = "sha256-v3JKEt/Yf+HRJOhAXIEUW5j4jRSpTp4w2tJHnEswZmk=";
          };

          propagatedBuildInputs = [
            cstruct
            poll
            ptime
            telemetry
            uri
          ];

          doCheck = false;
        };
      in
      {
        #packages = {
        #  default = pkgs.callPackage ./nix {
        #    inherit nix-filter;
        #    doCheck = true;
        #  };
        #};

        devShells = {
          default = pkgs.mkShell {
            #inputsFrom = [
            # self.packages.${system}.default
            #];

            propagatedBuildInputs = with pkgs.ocaml-ng.ocamlPackages_5_1; [
              eio
              eio_main
              riot
              telemetry
            ];

            nativeBuildInputs = with pkgs.ocaml-ng.ocamlPackages_5_1; [
              findlib

              ocaml
              dune

              ocaml-lsp

              ocamlformat
              dune-release
              odoc

              # benchmarks
              pkgs.go
              pkgs.rustc
              pkgs.cargo
            ];
          };
        };
      });
}
