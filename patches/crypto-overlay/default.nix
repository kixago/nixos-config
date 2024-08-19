{ nixpkgs, system, ... }:

let
  pkgs = import nixpkgs {
    inherit system;
  };
in
final: prev: {
  python3Packages = prev.python3Packages // {
    cryptography = pkgs.buildPythonPackage rec {
      pname = "cryptography";
      version = "39.0.2";

      src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "bc5b871e977c8ee5a1bbc42fa8d19bcc08baf0c51cbf1586b0e87a2694dde42f";
      };

      meta = with pkgs.lib; {
        description = "Cryptography library for Python";
        license = pkgs.lib.licenses.mit;
      };
    };
  };
}
