#! /bin/bash

# global aliases and functions
alias sha="shasum -a 256"
alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
# shellcheck disable=SC2139
alias vff="${HOME}/bin/vff.sh"
# shellcheck disable=SC2139
alias bgr="${HOME}/.bat/src/batgrep.sh"

alias gll='git log --graph --pretty=oneline --abbrev-commit'
alias gst='git status'
alias gco='git commit'

alias v='vim'
alias fd='fd -H'

alias lr='ls -lahtr'
alias ll='ls -lah'
if type l 2>/dev/null 1>&2; then
	unalias 'l'
fi
alias l='gls --color -lah --hyperlink=auto'

lb() {
	ls -lah --color=always $* | bat
}
export lb

logtail() {
	tail -f "$@" | bat --paging=never -l log
}

dnotify() {
	local title=$1
	shift 1
	IFS=" "
	local body=$*
	if [[ -z "${TMUX}" ]]; then
		printf "\x1b]99;i=1:d=0;%s\x1b\\" "${title}"
		printf "\x1b]99;i=1:d=1:p=body;%s\x1b\\" "${body}"
	else
		printf "\x1bPtmux;\x1b\x1b]99;i=1:d=0;%s\x1b\x1b\\" "${title}"
		printf "\x1b\x1b]99;i=1:d=1:p=body;%s\x1b\x1b\\" "${body}"
	fi
}

# load company / work specific aliases
# shellcheck source=./.company_aliases.sh
[[ ! -s "${HOME}/.company_aliases.sh" ]] || \. "${HOME}/.company_aliases.sh"
