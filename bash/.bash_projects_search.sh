#!/usr/bin/env bash

cd /home/lpocay/Projects/

SELECTED_PROJECT="$(fd -t d -d 1 | fzf)"

cd $SELECTED_PROJECT

tmux new
