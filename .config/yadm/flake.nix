{
  description = "Dotfiles package profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;

      forAllSystems = f: {
        aarch64-darwin = f "aarch64-darwin";
        x86_64-darwin  = f "x86_64-darwin";
        aarch64-linux  = f "aarch64-linux";
        x86_64-linux   = f "x86_64-linux";
      };

      # Single source of truth for all role/context package sets.
      # Keys map directly to yadm class values (role:*, context:*).
      # Profiles are additive — no package appears in more than one profile.
      profilePackages = pkgs:
        let
          # --- yadm: always installed, even with no class configured ---
          yadm-pkg = with pkgs; [ yadm ];

          # --- general: base tools always present on any configured machine ---
          general = (with pkgs; [
            atuin
            git
            neovim
            curl
            subversion
            gnupg
            openssh
            bat
            gh
            htop
            ripgrep
            shellcheck
            shfmt
            zoxide
            zsh-powerlevel10k
            delta
            difftastic
            eza
            fd
            fzf
            jq
            yq
            tmux
            watch
            wget
          ]) ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            coreutils
            gawk
            gnused
            gnutar
            pinentry_mac
            util-linux
          ]);

          # --- context profiles: additive, no overlap with general ---
          work    = with pkgs; [ boundary gradle rbenv pyenv nodeenv ];
          private = with pkgs; [ mosh ];

          # --- role profiles: additive, no overlap with general or context ---
          development = (with pkgs; [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            graphviz
            jdk
            jujutsu
            rustup
          ]) ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            tart
            softnet
          ]);
        in {
          # Always installed regardless of class selection.
          yadm = yadm-pkg;

          # Always installed when any class is configured.
          general = general;

          # Context profiles.
          work    = work;
          private = private;

          # Role profiles.
          development      = development;
          server           = [];
          "hardware-hacking" = [];
          photography      = [];
          gaming           = [];
          web              = [];
        };

    in {
      packages = forAllSystems (system:
        let
          pkgs     = import nixpkgs { inherit system; config.allowUnfree = true; };
          profiles = profilePackages pkgs;
          bundle   = name: paths:
            if paths == []
            then null
            else pkgs.symlinkJoin { inherit name paths; };
        in
          lib.filterAttrs (_: v: v != null)
            (builtins.mapAttrs (name: paths: bundle "${name}-tools" paths) profiles)
      );
    };
}
