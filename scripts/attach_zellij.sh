#!/bin/bash

# List sessions, clean up ANSI codes, extract session names, and allow user to select one with fzf
selected_session=$(zellij ls | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" | sed 's/\s.*$//' | fzf)

# Attach to the selected session if one was chosen
if [ -n "$selected_session" ]; then
    zellij a "$selected_session"
else
    echo "No session selected."
fi
