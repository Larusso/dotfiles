#
# This file is sourced automatically by xsh if the current shell is `zsh`.
#
# It should merely register the modules to be loaded for each runcom:
# env, login, interactive and logout.
# The order in which the modules are registered defines the order in which
# they will be loaded. Try `xsh help` for more information.
#

xsh module gpg              interactive
xsh module ssh              interactive
xsh module vim-mode         interactive
xsh module powerlevel10k    interactive
xsh module core             interactive:env:login
xsh module aws		    env
xsh module fzf              interactive
xsh module env              interactive
xsh module direnv           interactive
xsh module uvm              env
xsh module highlighter      interactive 
xsh module gradle           login
xsh module cargo            interactive
