#! /bin/bash

export DEBUG=false

source "${HOME}/.minimalrc"

GPG_TTY=$(tty)
export GPG_TTY
export EDITOR=vim
export VISUAL=vim
export MOSH_ESCAPE_KEY='~'

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

OSNAME=$("${UNAME}" -s)
OSRELEASE=$("${UNAME}" -r)
export OSNAME OSRELEASE

# LC_ALL would override all settings, do not set that
# LC_LANG is setting the default. It is set in /etc/default/locale
if [[ "${OSNAME}" != "Darwin" ]]; then
	export LC_COLLATE="C.UTF-8"
fi

if TMUX_VERS_BIN=$(tmux 2>/dev/null -V); then
	# get the correct tmux version, even if no server is running yet
	if TMUX_VERS_SERVER=$(tmux 2>/dev/null display-message -p "#{version}"); then
		# we got the server version, use this
		# shellcheck disable=SC2001
		TMUX_VERSION=$(echo "${TMUX_VERS_SERVER}" | sed -e 's/[^0-9.]*\([0-9.]*\)/\1/g')
	else
		# use the client version
		# shellcheck disable=SC2001
		TMUX_VERSION=$(echo "${TMUX_VERS_BIN}" | sed -e 's/[^0-9.]*\([0-9.]*\)/\1/g')
	fi
	export TMUX_VERSION
fi

# load authentication tokens
# shellcheck source=/home/rommel/.gh_credentials.sh
[[ -s "${HOME}/.gh_credentials.sh" ]] && source "${HOME}/.gh_credentials.sh"

# check for mintty to override TERM variable
# TERMINAL=$("${HOME}/bin/terminal.sh" -n)
# [[ "${TERMINAL}" == "mintty" ]] && export TERM=mintty
# [[ "${TERMINAL}" == "kitty" ]] && export TERM=kitty
# [[ "${TERMINAL}" == "linux" ]] && "${HOME}/bin/set_gruvbox_colors.sh"
# unset TERMINAL

# adjust gruvbos colors for 256 color terminals
# shellcheck source=/home/rommel/bin/set_gruvbox_colors.sh
[[ -s "${HOME}/bin/set_gruvbox_colors.sh" ]] && "${HOME}/bin/set_gruvbox_colors.sh"

# color for less and man
export MANPAGER='less -r -s -M +Gg'
# shellcheck source=./.less_colors.sh
[[ -f "$HOME/.less_colors.sh" ]] && source "$HOME/.less_colors".sh
# shellcheck source=./.dir_colors.sh
[[ -f "$HOME/.dir_colors.sh" ]] && source "$HOME/.dir_colors.sh"
# take over oh-my-zsh ls colors
# shellcheck source=./.ls_colors.sh
[[ -f "${HOME}/.ls_colors.sh" ]] && source "${HOME}/.ls_colors.sh"

echo -n " • mosh"
FATHER=$(ps -p $PPID -o comm=)
if [ "${FATHER}" = "mosh-server" ]; then
	echo -n " (true)"
	unset SSH_AUTH_SOCK
	unset SSH_CLIENT
	unset SSH_CONNECTION
	# leave TTY set, powerlevel10k uses it to determine context
	#unset SSH_TTY
	unset FATHER
fi

echo -n " • ssh-agent"
[[ ${DEBUG} == true ]] && echo -e -n "\nChecking for ssh keys"
ssh-add -l >/dev/null 2>&1
RC=$?
if [[ $RC == 1 || $RC == 2 ]]; then
	# there are no keys available or no agent running
	[[ ${DEBUG} == true ]] && echo " (none)"
	if [ "$(basename "${SHELL}")" = "zsh" ]; then
		# suppress error messages, when a glob pattern returns no matches
		setopt +o nomatch
	fi
	if [[ "${OSNAME}" == "Darwin" ]]; then
		# on macOS: keychain has support to get the passphrase from the OS Keyring
		# before you can use the keychain, you must add it once to it
		# ssh-add --apple-use-keychain ~/.ssh/id_ecdsa
		ssh-add -q --apple-load-keychain ~/.ssh/id_ecdsa
		eval "$(keychain --eval --agents ssh --inherit any-once id_ecdsa)"
	elif [[ "${OSNAME}" == "Linux" ]]; then
		if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
			# we are on WSL2
			# There is obviously no AUTH_SOCK available. Now keychain has its own
			# way of remembering an previously started agent in its .keychain
			# directory. It will therefore only start a wsl-relay once per
			# session.
			# Unfortunately keychain does not understand that the Windows OpenSSH
			# Agent already provides the identities and always thinks, if it started
			# the agent, it should ask to add keys, so we have to branch here and
			# not ask for identies to add.
			# Agent needs to be named "ssh-agent" because keychain refuses
			# to start anything other than ssh-agent and gpg-agent. :-(
			[[ ${DEBUG} == true ]] && echo "Launching ssh-agent relay"
			unset IDENTITIES
		else
			# per default add identities on other Linux systems
			declare -a IDENTITIES=(id_ed25519 id_ecdsa id_rsa)
		fi
		# inherit identities or start new ssh-agent
		[[ ${DEBUG} == false ]] && FLAG="--quiet"
		# shellcheck disable=SC2086,SC2068
		eval "$(keychain ${FLAG} --eval --ignore-missing \
			--agents ssh --inherit any-once ${IDENTITIES[@]})"
	else
		echo "Unknown Operating System: ${OSNAME}"
	fi
else
	[[ ${DEBUG} == true ]] && echo " (found)"
fi

umask 022
set -o vi

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'
