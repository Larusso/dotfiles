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

      # Single source of truth for all role/context package sets.
      # Keys map directly to yadm class values (role:*, context:*, type:*).
      # Home Manager will consume this same attrset via a module.
      rolePackages = pkgs: with pkgs;
        let
          # Internal lists — composed into profiles, not installed directly.
          base = [
            yadm
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
          ] ++ lib.optionals stdenv.isDarwin [
            coreutils
            gawk
            gnused
            gnutar
            pinentry_mac
            util-linux
          ];

          shell = [
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
          ];
        in {
          # --- context ---
          private = base ++ shell ++ [
            mosh
          ];

          work = base ++ shell ++ [
            boundary
            gradle
            rbenv
            pyenv
            nodeenv
          ];

          # --- type ---
          vm = [];

          # --- role ---
          general         = base ++ shell;
          development     = base ++ shell ++ [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            graphviz
            jdk25
            jujutsu
            rustup
          ] ++ lib.optionals stdenv.isDarwin [
            tart
            softnet
          ];
          server          = base ++ shell;
          hardware-hacking = base ++ shell;
          photography     = base ++ shell;
          gaming          = base ++ shell;
          web             = base ++ shell;
        };

    in {
      packages = forAllSystems (system:
        let
          pkgs   = import nixpkgs { inherit system; config.allowUnfree = true; };
          roles  = rolePackages pkgs;
          bundle = name: paths: pkgs.symlinkJoin { inherit name paths; };
        in
          builtins.mapAttrs (name: paths: bundle "${name}-tools" paths) roles
      );
    };
}
