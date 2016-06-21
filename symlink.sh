#!/bin/bash

echo "Symlinking dotfiles"

# need to be in the home
cd

ln -s dots/.gitconfig .gitconfig
ln -s dots/.nethackrc .nethackrc
ln -s dots/.tmux.conf .tmux.conf
ln -s dots/.vimrc .vimrc
ln -s dots/.zshrc .zshrc

ln -s dots/vimfiles .vim

echo "Done"
