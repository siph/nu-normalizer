{
  description = "Audio normalizer for media files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        buildInputs = with pkgs; [
          nushell
          ffmpeg
        ];
      in with pkgs; rec {
        packages = {
          nu-normalizer = stdenv.mkDerivation rec {
            nativeBuildInputs = [ makeWrapper ];
            inherit buildInputs;
            name = "nu-normalizer";
            src = ./.;
            installPhase = ''
              mkdir -p $out/bin
              mkdir -p $out/nu
              cp ./${name}.nu $out/nu
              makeWrapper ${nushell}/bin/nu $out/bin/${name} \
                --add-flags "$out/nu/${name}.nu"
            '';
          };
          default = packages.nu-normalizer;
        };
        apps = {
          nu-normalizer = flake-utils.lib.mkApp { drv = packages.nu-normalizer; };
          default = apps.nu-normalizer;
        };
        devShells = {
          default = mkShell {
            inherit buildInputs;
          };
        };
      });
}
