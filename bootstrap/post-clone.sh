#! /usr/bin/env bash

source "${HOME}/.homesick/helper.sh"

echo "Installing basic packages"
if is_mac; then
	desired=(mosh keychain ncurses gawk autoconf automake pkg-config coreutils imagemagick oh-my-posh)
	missing=()
	check_brewed "missing" "${desired[@]}"
	if [[ "${#missing[@]}" -gt 0 ]]; then
		echo "(brew) installing ${missing[*]}"
		brew install "${missing[@]}"
	fi
else
	desired=(curl git vim mosh keychain zsh ncurses-bin apt-file
		unzip sysstat net-tools dnsutils bc gawk universal-ctags
		software-properties-common socat)
	missing=()
	check_dpkged "missing" "${desired[@]}"
	if [[ "${#missing[@]}" -gt 0 ]]; then
		echo "(apt) installing ${missing[*]}"
		sudo apt-get -y update
		sudo apt-get -y install "${missing[@]}"
	fi
fi

if ! is_mac && [[ ! -d "${HOME}/.oh-my-posh" ]]; then
	echo "Installing oh-my-posh for zsh"
	mkdir -p "${HOME}/.cache"
	mkdir -p "${HOME}/.oh-my-posh"
	export PATH="${HOME}/.oh-my-posh:${PATH}"
	curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "${HOME}/.oh-my-posh"
fi

if [[ ! -d "${HOME}/.zsh/zsh-autosuggestions" ]]; then
	mkdir -p "${HOME}/.zsh"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
fi

cd "${HOME}" || exit
touch .hushlogin

if is_wsl; then
	# compile the npiperelay program if it is not already existing
	NPR=/mnt/c/ProgramFiles/npiperelay/npiperelay.exe
	if [[ ! -f "${NPR}" ]]; then
		# -d says not to install the poackage
		go get -d github.com/jstarks/npiperelay
		GOOS=windows go build -o ${NPR} github.com/jstarks/npiperelay
	fi
fi

GIT_VERSION=$(git --version | sed -e 's/git version \([0-9]*\.[0-9]*\)\..*/\1/')
#if (($(echo "${GIT_VERSION} < 2.26" | bc -l))); then
if ! satisfied "2.26" "${GIT_VERSION}"; then
	if ! is_mac; then
		source /etc/os-release
		if [[ ${VERSION_CODENAME} == "buster" ]]; then
			echo "Adding buster backports"
			echo "deb http://deb.debian.org/debian buster-backports main" |
				sudo tee /etc/apt/sources.list.d/buster-backports.list
			sudo apt update
			sudo apt install -y -t buster-backports git
		else
			echo "git is outdated, you should build git from source"
			# cd "${HOME}" || exit
			# mkdir -p "${HOME}/software"; cd "${HOME}/software" || exit
			# git clone git://git.kernel.org/pub/scm/git/git.git
			# sudo apt remove -y git
			# cd git || exit
			# make configure
			# ./configure --prefix=/usr
			# make all info
			# sudo make install install-info
		fi
	fi
fi

cd "${HOME}" || exit
# if ! is_mac; then
# 	MYSH=$(getent passwd "${LOGNAME}" | cut -d: -f7)
# 	if [[ ! $MYSH =~ "zsh" ]]; then
# 		sudo chsh -s /usr/bin/zsh "${LOGNAME}"
# 	fi
# fi
