#
# This file is sourced automatically by xsh if the current shell is `zsh`.
#
# It should merely register the modules to be loaded for each runcom:
# env, login, interactive and logout.
# The order in which the modules are registered defines the order in which
# they will be loaded. Try `xsh help` for more information.
#

xsh module core             interactive:env:login
xsh module gpg              interactive
xsh module git              env 
xsh module ssh              interactive
xsh module docker           env 
xsh module vim-mode         interactive
xsh module powerlevel10k    interactive
xsh module aws		        interactive:env
xsh module fzf              interactive
#xsh module atuin            interactive
xsh module env              env
xsh module direnv           interactive
xsh module uvm              env
xsh module highlighter      interactive 
xsh module gradle           login
xsh module cargo            interactive
xsh module emacs            interactive:login
xsh module boundry          interactive
