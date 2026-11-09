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

      profilePackages = pkgs:
        let
          # Shared packages now live in home/home.nix.
          # Role packages below must not repeat those.

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

          # Shared base is installed by Home Manager, not a Nix profile.
          general_work_physical    = null;
          general_work_vm          = null;
          general_private_physical = null;
          general_private_vm       = null;

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
