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

          gnu = lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs; [
            coreutils   # needed by xsh (GNU ln) and general linux-compat
            gawk
            gnused
            gnutar
            util-linux
            imgcat
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
          ]) ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.pinentry_mac ]
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

          dev_private_physical_extra = lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs; [
            softnet
            tart
          ]);

          nonEmpty = ps: if ps == [] then null else ps;

          mlx_python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.mlx-lm ]);

          # llmfit and llmserve both probe MLX with `python3 -c "import mlx_lm"`,
          # and llmserve launches it as `python3 -m mlx_lm.server`.
          # python3Packages.mlx-lm only installs the mlx_lm.* scripts.
          withMlxOnDarwin = drv: bin:
            if pkgs.stdenv.hostPlatform.isDarwin then
              pkgs.symlinkJoin {
                name = "${bin}-with-mlx";
                paths = [ drv ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/${bin} --prefix PATH : ${lib.makeBinPath [ mlx_python ]}
                '';
              }
            else drv;

          local_ai_ramalama = pkgs.symlinkJoin {
            name = "ramalama-native";
            paths = [ (pkgs.ramalama.override {
              withPodman = false;
              llama-cpp-vulkan = pkgs.llama-cpp;
            }) ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/ramalama --set-default RAMALAMA_IN_CONTAINER false
            '';
          };

          # llmserve always scans ~/.cache/llmfit/models. On Darwin, llmfit stores
          # GGUF files in ~/Library/Caches/llmfit/models (dirs::cache_dir) and
          # ignores XDG_CACHE_HOME. The symlink is the path llmserve already
          # knows. MLX pulls go through `hf download` into ~/.cache/huggingface/hub,
          # which llmserve scans on its own. Leave HF_HOME unset: llmserve treats
          # that variable as the hub directory, while Hugging Face uses $HF_HOME/hub.
          local_ai_llmfit = if pkgs.stdenv.hostPlatform.isDarwin then
            pkgs.symlinkJoin {
              name = "llmfit-with-mlx";
              paths = [ pkgs.llmfit ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/llmfit \
                  --prefix PATH : ${lib.makeBinPath [ mlx_python pkgs.python3Packages.huggingface-hub ]} \
                  --run 'if [ ! -e "$HOME/.cache/llmfit/models" ]; then mkdir -p "$HOME/.cache/llmfit" "$HOME/Library/Caches/llmfit/models" && ln -s "$HOME/Library/Caches/llmfit/models" "$HOME/.cache/llmfit/models"; fi'
              '';
            }
          else pkgs.llmfit;
          local_ai_llmserve = withMlxOnDarwin pkgs.llmserve "llmserve";

          # The clortho shim does not forward PI_CODING_AGENT_DIR. Set the XDG
          # default in the wrapper so discovery still uses ~/.config/pi/extensions.
          local_ai_pi = pkgs.symlinkJoin {
            name = "pi-with-agent-dir";
            paths = [ pkgs.pi-coding-agent ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/pi \
                --run 'export PI_CODING_AGENT_DIR="''${PI_CODING_AGENT_DIR:-''${XDG_CONFIG_HOME:-$HOME/.config}/pi}"'
            '';
          };

          local_ai = [
            local_ai_llmfit
            local_ai_llmserve
            pkgs.ollama
            pkgs.llama-cpp
            pkgs.lmstudio
            local_ai_pi
            pkgs.opencode
            local_ai_ramalama
          ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            pkgs.python3Packages.mlx-lm
            (pkgs.writeShellScriptBin "lm-studio" ''
              exec /usr/bin/open -a "${pkgs.lmstudio}/Applications/LM Studio.app" "$@"
            '')
            (pkgs.writeShellScriptBin "lms" ''
              exec "${pkgs.lmstudio}/Applications/LM Studio.app/Contents/Resources/app/.webpack/lms" "$@"
            '')
          ];

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

          "local-ai_work_physical"    = nonEmpty local_ai;
          "local-ai_work_vm"          = nonEmpty local_ai;
          "local-ai_private_physical" = nonEmpty local_ai;
          "local-ai_private_vm"       = nonEmpty local_ai;

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
