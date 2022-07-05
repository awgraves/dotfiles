#!/bin/bash

which brew &> /dev/null || { echo "brew not installed! do that first." ; exit 1 ; }

which nvim &> /dev/null || { brew install neovim || { echo "failed to install neovim" ; exit 1 ; } }

VIM_CONFIG=~/.config/nvim/init.vim/
test -e $VIM_CONFIG || { echo "no init.vim found" ; mkdir -p ~/.config/nvim ; ln -s $(pwd)/$VIM_CONFIG ; echo "symlink created" ; }

VIM_PLUG=~/.local/share/nvim/site/autoload/plug.vim
test -e $VIM_PLUG || { echo "missing vim-plug" ; curl -fLo ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ; } || { echo "failed to curl vim-plug repo." ; exit 1 ; }

echo "Neovim setup complete! Run 'nvim +PlugInstall' to initialize the plugins"
