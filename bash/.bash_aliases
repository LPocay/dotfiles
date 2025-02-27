PROMPT_COMMAND='PS1_CMD1=$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git branch --show-current 2>/dev/null || echo "")'
PS1='💩 [\[\e[38;5;105m\]\u\[\e[0m\]@\[\e[38;5;71m\]\h\[\e[0m\]] \[\e[38;5;167;1m\]/\W\[\e[0m\]${PS1_CMD1:+ \[\e[38;5;255;2m\](${PS1_CMD1})}\[\e[0m\] \\$ '

alias ll='eza -l -g --icons'
alias fzf="fzf --preview 'bat --style=numbers --theme=TwoDark --color=always --line-range :500 {}'"
alias lla='ll -la'

eval "$(fzf --bash)"
eval "$(zoxide init bash)"

bind -x '"\C-f": "~/attach_zellij.sh"'

fastfetch
