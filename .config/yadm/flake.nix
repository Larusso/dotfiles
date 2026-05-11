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

      profilePackages = pkgs:
        let
          # ── Shared base layer ────────────────────────────────────────────
          # Lives in general_{context}_{type}, always installed.
          # Anything needed by more than one role must go here.

          gnu = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            coreutils   # needed by xsh (GNU ln) and general linux-compat
            gawk
            gnused
            gnutar
            util-linux
          ]);

          base = (with pkgs; [
            atuin
            bat
            curl
            delta
            difftastic
            eza
            fd
            fzf
            gh
            git
            gnupg
            htop
            jq
            neovim
            openssh
            ripgrep
            shellcheck
            shfmt
            subversion
            tmux
            watch
            wget
            yq
            zoxide
            zsh-powerlevel10k
          ]) ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.pinentry_mac ]
            ++ gnu;

          # ── Role-unique packages ─────────────────────────────────────────
          # No package here may appear in base or in another role profile.

          dev_work = with pkgs; [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            graphviz
            jdk
            jujutsu
            rustup
          ];

          dev_work_physical_extra = with pkgs; [
            boundary
            gradle
            nodeenv
            pyenv
            rbenv
          ];

          dev_private = with pkgs; [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            jujutsu
          ];

          dev_private_physical_extra = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            softnet
            tart
          ]);

          nonEmpty = ps: if ps == [] then null else ps;

        in {
          # Always installed, no matter what.
          yadm = with pkgs; [ yadm ];

          # Always installed when context + type are configured.
          # Contains the full base shell environment shared by all roles.
          general_work_physical    = base;
          general_work_vm          = base;
          general_private_physical = base;
          general_private_vm       = base;

          # Role deltas — unique packages only, no overlap with base or each other.
          development_work_physical    = nonEmpty (dev_work ++ dev_work_physical_extra);
          development_work_vm          = nonEmpty dev_work;
          development_private_physical = nonEmpty (dev_private ++ dev_private_physical_extra);
          development_private_vm       = nonEmpty dev_private;

          # Remaining roles have no nix-specific packages yet.
          # Add packages here when needed; null means no profile is exposed.
          server_work_physical    = null;
          server_work_vm          = null;
          server_private_physical = null;
          server_private_vm       = null;

          "hardware-hacking_work_physical"    = null;
          "hardware-hacking_work_vm"          = null;
          "hardware-hacking_private_physical" = null;
          "hardware-hacking_private_vm"       = null;

          photography_work_physical    = null;
          photography_work_vm          = null;
          photography_private_physical = null;
          photography_private_vm       = null;

          gaming_work_physical    = null;
          gaming_work_vm          = null;
          gaming_private_physical = null;
          gaming_private_vm       = null;

          web_work_physical    = null;
          web_work_vm          = null;
          web_private_physical = null;
          web_private_vm       = null;
        };

    in {
      packages = forAllSystems (system:
        let
          pkgs     = import nixpkgs { inherit system; config.allowUnfree = true; };
          profiles = profilePackages pkgs;
          bundle   = name: paths: pkgs.symlinkJoin { inherit name paths; };
        in
          lib.filterAttrs (_: v: v != null)
            (builtins.mapAttrs
              (name: paths: if paths == null then null else bundle "${name}-tools" paths)
              profiles)
      );
    };
}
