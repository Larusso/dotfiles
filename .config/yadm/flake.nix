{
  description = "Dotfiles package profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: {
        aarch64-darwin = f "aarch64-darwin";
        x86_64-darwin  = f "x86_64-darwin";
        aarch64-linux  = f "aarch64-linux";
        x86_64-linux   = f "x86_64-linux";
      };
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

          bundle = name: paths: pkgs.symlinkJoin { inherit name paths; };

          # Installed on every machine
          base = with pkgs; [
            atuin
            bat
            zsh-powerlevel10k
            delta
            difftastic
            eza
            fd
            fzf
            gh
            htop
            jq
            ripgrep
            shellcheck
            shfmt
            tmux
            watch
            wget
            yq
            zoxide
            boundary
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            coreutils
            gawk
            gnused
            gnutar
          ];

          # Added on machines used for active development
          development = base ++ (with pkgs; [
            act
            awscli2
            dash
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            graphviz
            jdk25
            jujutsu
            saml2aws
          ]);

        in {
          # All machines get at least this
          base           = bundle "base-tools"           base;

          # Terminal/SSH machine — light, no dev layer
          home-secondary = bundle "home-secondary-tools" (base ++ [ pkgs.mosh ]);

          # Mac Mini M4 Pro — full dev setup
          home-primary   = bundle "home-primary-tools"   development;

          # Work MacBook — full dev setup
          work-primary   = bundle "work-primary-tools"   development;

          default        = bundle "base-tools"           base;
        }
      );
    };
}
