{
  description = "NixOS microVM environments for AI coding agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = pkgs.lib;
      version = "1.2.1";

      # Minimal runtime dependencies for the nixcage script
      runtimeDeps = with pkgs; [
        bash
        openssh
      ];

      # Nixcage package derivation
      nixcagePkg = pkgs.stdenv.mkDerivation {
        pname = "nixcage";
        inherit version;
        src = ./.;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin
          cp nixcage $out/bin/nixcage
          chmod +x $out/bin/nixcage
          wrapProgram $out/bin/nixcage \
            --prefix PATH : ${lib.makeBinPath runtimeDeps}
        '';
      };
    in
    {
      packages.${system}.default = nixcagePkg;

      nixosModules.base = import ./modules/vm-base.nix;
    };
}
