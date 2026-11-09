# Git values for this profile. programs.git.enable stays off.
{ ... }:
{
  programs.git = {
    enable = false;

    sshCommand = "\${XDG_BIN_HOME:-$HOME/.local/bin}/ssh_logger";

    signing = {
      format = "ssh";
      key = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRRi448XEYM9BLr1kMyeNUUASAoeZBJP0y5+HLTZqUH";
      signByDefault = true;
      signer = "~/.local/bin/ssh-keygen-1p";
    };

    includes = [
      { condition = "gitdir:work/wooga/"; path = "wooga.gitconfig"; }
      { condition = "gitdir:work/mothership/"; path = "mothership.gitconfig"; }
      { path = "../delta/themes.gitconfig"; }
      { path = "platform_specific.gitconfig"; }
    ];

    settings = {
      alias = {
        ci = "commit";
        co = ''!f() { if [[ "$1" == "-i" ]]; then shift; git cof "$@"; else git checkout "$@"; fi; }; f'';
        commend = "commit --amend --no-edit";
        fix-message = "commit --amend --allow-empty";
        lg = "!git lg1";
        graph = "!git lg";
        lg1 = ''!sh -c "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' $*"'';
        lg2 = ''!sh -c "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' $*"'';
        lg3 = ''!sh -c "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(bold yellow)%d%C(reset)%n'''          %C(white)%s%C(reset)%n'''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)' $*"'';
        last-commit = ''!sh -c "git log -1 --pretty=tformat:\"%H\" --author=\"'git config user.name'\" $*"'';
        make-private = ''config user.email "manfred.endres@tslarusso.de"'';
        make-wooga = ''config user.email "manfred.endres@wooga.net"'';
        next = ''!git co $(git log master --reverse --ancestry-path HEAD..master --pretty=tformat:"%H" | head -1)'';
        prev = ''!git co $(git rev-list --first-parent --max-count=2 HEAD | tail -1)'';
        prune-all = "!git remote | xargs -n 1 git remote prune";
        prune-merged = "!git branch -d $(git branch --merged)";
        st = "status -s";
      };

      color.ui = "auto";
      column.ui = "auto";

      core = {
        autocrlf = "input";
        commitGraph = true;
        editor = "nvim";
        quotepath = false;
        pager = "delta";
        attributesfile = ".gitattributes";
      };

      interactive.diffFilter = "delta --color-only";

      delta = {
        "true-color" = "always";
        navigate = true;
        dark = true;
        "side-by-side" = false;
        "line-numbers" = false;
      };

      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3";
        mergiraf = {
          name = "mergiraf";
          driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
        };
      };

      pull.rebase = true;

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      rebase = {
        autoStash = true;
        updateRefs = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      user = {
        email = "manfred.endres@tslarusso.de";
        name = "Manfred Endres";
        useConfigOnly = true;
      };

      difftool = {
        prompt = false;
        trustExitCode = true;
        kitty.cmd = "kitty +kitten diff $LOCAL $REMOTE";
        "kitty.gui".cmd = "kitty kitty +kitten diff $LOCAL $REMOTE";
        difftastic.cmd = ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
      };

      init.defaultBranch = "master";
      mergetool.prompt = false;
      pager.difftool = true;

      url."git@github-wooga:wooga/".insteadOf = [
        "git@github.com:wooga/"
        "https://github.com/wooga/"
      ];

      http = {
        sslCAPath = "/Library/Certs/Cacert.pem";
        sslCAInfo = "/Library/Certs/Cacert.pem";
      };
    };
  };
}
