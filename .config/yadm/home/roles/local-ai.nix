{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;

  mlxPython = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.mlx-lm ]);

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
          wrapProgram $out/bin/${bin} --prefix PATH : ${lib.makeBinPath [ mlxPython ]}
        '';
      }
    else drv;

  # llmserve always scans ~/.cache/llmfit/models. On Darwin, llmfit stores
  # GGUF files in ~/Library/Caches/llmfit/models and ignores XDG_CACHE_HOME.
  llmfit =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.symlinkJoin {
        name = "llmfit-with-mlx";
        paths = [ pkgs.llmfit ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/llmfit \
            --prefix PATH : ${lib.makeBinPath [ mlxPython pkgs.python3Packages.huggingface-hub ]} \
            --run 'if [ ! -e "$HOME/.cache/llmfit/models" ]; then mkdir -p "$HOME/.cache/llmfit" "$HOME/Library/Caches/llmfit/models" && ln -s "$HOME/Library/Caches/llmfit/models" "$HOME/.cache/llmfit/models"; fi'
        '';
      }
    else pkgs.llmfit;

  llmserve = withMlxOnDarwin pkgs.llmserve "llmserve";

  # The clortho shim does not forward PI_CODING_AGENT_DIR. Set the XDG
  # default so discovery still uses ~/.config/pi/extensions.
  pi = pkgs.symlinkJoin {
    name = "pi-with-agent-dir";
    paths = [ pkgs.pi-coding-agent ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --run 'export PI_CODING_AGENT_DIR="''${PI_CODING_AGENT_DIR:-''${XDG_CONFIG_HOME:-$HOME/.config}/pi}"'
    '';
  };

  ramalama = pkgs.symlinkJoin {
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

  darwinOnly = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.python3Packages.mlx-lm
    (pkgs.writeShellScriptBin "lm-studio" ''
      exec /usr/bin/open -a "${pkgs.lmstudio}/Applications/LM Studio.app" "$@"
    '')
    (pkgs.writeShellScriptBin "lms" ''
      exec "${pkgs.lmstudio}/Applications/LM Studio.app/Contents/Resources/app/.webpack/lms" "$@"
    '')
  ];
in
{
  config = lib.mkIf (builtins.elem "local-ai" cfg.roles) {
    home.packages = [
      llmfit
      llmserve
      pkgs.ollama
      pkgs.llama-cpp
      pkgs.lmstudio
      pi
      pkgs.opencode
      ramalama
    ] ++ darwinOnly;
  };
}
