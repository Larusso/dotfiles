{ config, lib, pkgs, ... }:

{
  imports = [
    ./profiles.nix
    ./machine.nix
    ./git.nix
    ./_modules
    ./modules
    ./roles/editor.nix
    ./roles/development
    ./roles/local-ai.nix
  ];

  # Username, home directory, and profile selection come from machine.nix,
  # which yadm alt generates for this machine.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
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
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # GNU userland for xsh, plus the macOS pinentry.
    coreutils
    gawk
    gnused
    gnutar
    util-linux
    imgcat
    pinentry_mac
  ];

  # Values for the base tools. Enable stays off; the modules write these
  # once a profile sets enable = true.
  programs.fzf = {
    enable = false;
    keyBindings = true;
    completion = true;
    defaultOptions = [ "--no-reverse" ];
    fileWidget.options = [ "--select-1" "--exit-0" ];
    historyWidget.options = [
      "--preview 'echo {}'"
      "--preview-window down:3:hidden:wrap"
      "--bind '?:toggle-preview'"
    ];
    changeDirWidget.options = [ "--preview 'eza --tree {} | head -200'" ];
  };

  programs.atuin = {
    enable = false;
    noBind = true;
    historyWidget = true;
    keys = [ "^r" "^[[A" "^[OA" ];
  };

  programs.powerlevel10k =
    let
      rainbow = import ./modules/p10k-rainbow.nix;
      linux = import ./modules/p10k-linux.nix;
    in
    {
      enable = false;
      instantPrompt = true;
      settings = rainbow.settings;
      sshSettings = rainbow.sshSettings;
      gitFormatter = rainbow.gitFormatter;
      linux = {
        settings = linux.settings;
        sshSettings = linux.sshSettings;
        gitFormatter = linux.gitFormatter;
      };
    };

  programs.gpg = {
    enable = false;
    sshSupport = config.profiles.context == "work";
    settings = lib.mkForce { };
  };

  shell.ssh = {
    enable = false;
    agentLifetime = "1h";
    startAgentOnLinux = true;
  };

  shell.highlighter.enable = false;

  shell.vimMode = {
    enable = false;
    plugin = "\${XDG_CONFIG_HOME:-$HOME/.config}/shell/zsh/vim-mode/zsh-vim-mode/zsh-vim-mode.plugin.zsh";
  };

  shell.docker = {
    enable = false;
    host = "unix://$XDG_RUNTIME_DIR/docker.sock";
    linuxOnly = true;
  };

  shell.emacs = {
    enable = false;
    userBin = "$HOME/.emacs.d/bin";
    emax = true;
  };

  shell.ai = {
    enable = false;
    workBase = "$HOME/work";
    commandWrappers = true;
    profiles = {
      localOverrides = "$HOME/.config/agent-safehouse/local-overrides.sb";
      cargo = "\${XDG_CACHE_HOME:-$HOME/.cache}/agent-safehouse/cargo.sb";
      claude = "$HOME/.config/agent-safehouse/claude.sb";
      codex = "$HOME/.config/agent-safehouse/codex.sb";
      cursor = "$HOME/.config/agent-safehouse/cursor.sb";
      gemini = "$HOME/.config/agent-safehouse/gemini.sb";
      nix = "$HOME/.config/agent-safehouse/nix.sb";
      dotnet = "$HOME/.config/agent-safehouse/dotnet.sb";
      docker = "$HOME/.config/agent-safehouse/docker.sb";
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
