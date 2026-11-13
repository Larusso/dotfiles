# Tool modules declare options and write config or shell files when
# those options are set and the module is enabled. Profiles set the
# values. Enable stays off until a profile turns a module on.
{
  imports = [
    ./example-tool.nix
    ./aws.nix
    ./git.nix
    ./docker.nix
    ./pyenv.nix
    ./rbenv.nix
    ./jenv.nix
    ./nodenv.nix
    ./gradle.nix
    ./emacs.nix
    ./fzf.nix
    ./powerlevel10k.nix
    ./direnv.nix
    ./mise.nix
    ./cargo.nix
    ./atuin.nix
    ./gpg.nix
    ./ssh.nix
    ./llm.nix
    ./ai.nix
    ./highlighter.nix
    ./vim-mode.nix
    ./boundary.nix
  ];
}
