#!/bin/bash
mv ~/.vimrc ~/.vimrc.org
ln -s `pwd`/.vimrc ~/.vimrc
mv ~/.vim ~/.vim.org
ln -s `pwd` ~/.vim
