PROMPT_COMMAND='PS1_CMD1=$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git branch --show-current 2>/dev/null || echo "")'
PS1='💩 [\[\e[38;5;105m\]\u\[\e[0m\]@\[\e[38;5;71m\]\h\[\e[0m\]] \[\e[38;5;167;1m\]/\W\[\e[0m\]${PS1_CMD1:+ \[\e[38;5;255;2m\](${PS1_CMD1})}\[\e[0m\] \\$ '

alias ll='eza -l -g --icons'
# alias fzf="fzf --preview 'bat --style=numbers --theme=TwoDark --color=always --line-range :500 {}'"
alias lla='ll -la'

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

bind -x '"\C-f": "bash \"$HOME/dotfiles/scripts/attach_zellij.sh\""'

if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
