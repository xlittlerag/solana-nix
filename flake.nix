{
  description = "Solana development setup with Nix.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b2a3852bd078e68dd2b3dfa8c00c67af1f0a7d20";
    flake-parts.url = "github:hercules-ci/flake-parts/4524271976b625a4a605beefd893f270620fd751";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    rust-overlay = {
      url = "github:oxalica/rust-overlay/067b3536e55341f579385ce8593cdcc9d022972b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };
  outputs = inputs @ {
    self,
    flake-parts,
    crane,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-windows"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        solana-source = pkgs.callPackage ./solana-source.nix {};
        solana-platform-tools = pkgs.callPackage ./solana-platform-tools.nix {
          inherit solana-source;
        };
        solana-rust = pkgs.callPackage ./solana-rust.nix {
          inherit solana-platform-tools;
        };
        solana-cli = pkgs.callPackage ./solana-cli.nix {
          inherit solana-platform-tools solana-source;
          crane = crane.mkLib pkgs;
        };
        anchor-cli = pkgs.callPackage ./anchor-cli.nix {
          inherit solana-platform-tools;
          crane = crane.mkLib pkgs;
        };
        anchor-test = pkgs.callPackage ./anchor-test.nix {
          inherit anchor-cli solana-cli solana-rust;
        };
      in {
        overlayAttrs = {
          inherit
            (config.packages)
            solana-source
            solana-platform-tools
            solana-rust
            solana-cli
            anchor-cli
            anchor-test
            ;
        };
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
            self.overlays.default
          ];
        };

        devShells.default = pkgs.mkShell {
          packages = [
            anchor-cli
            solana-cli
            solana-rust
            pkgs.yarn
            pkgs.nodejs
            pkgs.nixfmt-rfc-style
          ];
        };

        packages = {
          inherit
            anchor-cli
            solana-cli
            solana-platform-tools
            solana-rust
            anchor-test
            ;
        };
      };
    };
}
