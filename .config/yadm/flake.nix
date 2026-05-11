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
          # Base shell tools — present in every role profile.
          # yadm is excluded here; it lives in the standalone yadm profile.
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
          ]) ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.pinentry_mac ];

          # GNU userland — development / linux-compat only, macOS only.
          gnu = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            coreutils
            gawk
            gnused
            gnutar
            util-linux
          ]);

          # Development tools shared by all work development profiles.
          dev_work = (with pkgs; [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            graphviz
            jdk
            jujutsu
            rustup
          ]);

          # Extra tools only on a physical work dev machine.
          dev_work_physical_extra = with pkgs; [
            boundary
            gradle
            nodeenv
            pyenv
            rbenv
          ];

          # Development tools shared by all private development profiles.
          dev_private = (with pkgs; [
            act
            awscli2
            (direnv.overrideAttrs (_: { doCheck = false; }))
            git-crypt
            git-lfs
            jujutsu
          ]);

          # VM tooling only on a private physical dev machine.
          dev_private_physical_extra = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            softnet
            tart
          ]);

        in {
          # Always installed regardless of class selection.
          yadm = with pkgs; [ yadm ];

          # role: general
          general_work_physical    = base;
          general_work_vm          = base;
          general_private_physical = base;
          general_private_vm       = base;

          # role: development
          development_work_physical    = base ++ dev_work ++ dev_work_physical_extra ++ gnu;
          development_work_vm          = base ++ dev_work ++ gnu;
          development_private_physical = base ++ dev_private ++ dev_private_physical_extra ++ gnu;
          development_private_vm       = base ++ dev_private ++ gnu;

          # role: server
          server_work_physical    = base ++ gnu;
          server_work_vm          = base ++ gnu;
          server_private_physical = base ++ gnu;
          server_private_vm       = base ++ gnu;

          # role: hardware-hacking
          "hardware-hacking_work_physical"    = base ++ gnu;
          "hardware-hacking_work_vm"          = base ++ gnu;
          "hardware-hacking_private_physical" = base ++ gnu;
          "hardware-hacking_private_vm"       = base ++ gnu;

          # role: photography
          photography_work_physical    = base;
          photography_work_vm          = base;
          photography_private_physical = base;
          photography_private_vm       = base;

          # role: gaming
          gaming_work_physical    = base;
          gaming_work_vm          = base;
          gaming_private_physical = base;
          gaming_private_vm       = base;

          # role: web
          web_work_physical    = base;
          web_work_vm          = base;
          web_private_physical = base;
          web_private_vm       = base;
        };

    in {
      packages = forAllSystems (system:
        let
          pkgs     = import nixpkgs { inherit system; config.allowUnfree = true; };
          profiles = profilePackages pkgs;
          bundle   = name: paths: pkgs.symlinkJoin { inherit name paths; };
        in
          builtins.mapAttrs (name: paths: bundle "${name}-tools" paths) profiles
      );
    };
}
