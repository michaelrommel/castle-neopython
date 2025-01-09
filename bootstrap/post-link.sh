#! /bin/bash

source "${HOME}/.homesick/helper.sh"

if is_wsl; then
	echo "Linking wsl2-relay as ssh-agent"
	# on WSL2 install a shell script with npiperelay as ssh-agent
	cd "${HOME}/bin" || exit
	ln -sf wsl2-relay-agent.sh ssh-agent
fi

echo "Creating current terminfo files"
cd "${HOME}" || exit
/usr/bin/tic -x "${HOME}/.terminfo_src/tmux.terminfo"
/usr/bin/tic -x "${HOME}/.terminfo_src/mintty.terminfo"
if is_mac; then
	if ! infocmp xterm-kitty 2>/dev/null 1>&2; then
		sudo /usr/bin/tic -x "${HOME}/.terminfo_src/xterm-kitty.terminfo" 2>/dev/null
	fi
else
	/usr/bin/tic -x "${HOME}/.terminfo_src/xterm-kitty.terminfo" 2>/dev/null
fi

# paths for mise and shims
source "${HOME}/.path.d/50_mise.bash"
source "${HOME}/.path.d/99_default.sh"

if ! node --version >/dev/null 2>&1; then
	echo "Installing node"
	mise install node@latest
	mise use -g node@latest
fi

if ! is_mac; then
	echo "Updating font cache"
	fc-cache -f
fi
