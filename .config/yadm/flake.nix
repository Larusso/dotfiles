{
  description = "Dotfiles package profiles and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f: lib.genAttrs systems f;

      profilePackages = pkgs: {
        yadm = with pkgs; [ yadm ];
      };

    in {
      packages = forAllSystems (system:
        let
          pkgs     = import nixpkgs { inherit system; config.allowUnfree = true; };
          profiles = profilePackages pkgs;
          bundle   = name: paths: pkgs.symlinkJoin { inherit name paths; };
        in
          {
            # Home Manager drops x86_64-darwin from its flake packages.
            home-manager =
              if home-manager.packages ? ${system}
              then home-manager.packages.${system}.home-manager
              else pkgs.home-manager;
          }
          // lib.filterAttrs (_: v: v != null)
            (builtins.mapAttrs
              (name: paths: if paths == null then null else bundle "${name}-tools" paths)
              profiles)
      );

      # machine.nix is rendered by yadm alt from the classes picked at bootstrap.
      homeConfigurations = forAllSystems (system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ ./home/home.nix ];
        }
      );
    };
}
