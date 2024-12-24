{ pkgs ? import <nixpkgs> {} }:
let
  libPath = with pkgs;
    lib.makeLibraryPath [
    ];
in
  pkgs.mkShell rec {
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      powershell
    ];

    shellHook = ''
      export LD_LIBRARY_PATH=${libPath}
    '';
  }
