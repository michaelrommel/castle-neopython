#! /usr/bin/env bash

source "${HOME}/.homesick/helper.sh"

echo "Installing basic packages"
# gawk needed for plugins
desired=(build-essential autoconf automake pkg-config
	libevent-dev libncurses5-dev libutf8proc-dev
	libutf8proc2 byacc gawk
	curl git vim mosh keychain zsh ncurses-bin apt-file
	unzip sysstat net-tools dnsutils bc gawk universal-ctags
	software-properties-common socat)
missing=()
check_dpkged "missing" "${desired[@]}"
if [[ "${#missing[@]}" -gt 0 ]]; then
	echo "(apt) installing ${missing[*]}"
	sudo apt-get -y update
	sudo apt-get -y install "${missing[@]}"
fi

if ! is_mac && [[ ! -d "${HOME}/.oh-my-posh" ]]; then
	echo "Installing oh-my-posh for bash"
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
echo "Recompiling tmux"
mkdir -p "${HOME}/software"
cd "${HOME}/software" || exit
git clone https://github.com/tmux/tmux.git tmux_src
cd "${HOME}/software/tmux_src" || exit
# optionally use a specific version
# git checkout 3.5xxx
sh autogen.sh
FLAGS="--enable-utf8proc"
./configure ${FLAGS} --prefix="${HOME}/software/tmux"
make
make install

echo "Configuring tmux plugins"
mkdir -p "${HOME}/.local/share/tmux/plugins"
cd "${HOME}/.local/share/tmux/plugins" || exit
if [[ ! -d "tpm" ]]; then
	git clone --depth=1 https://github.com/tmux-plugins/tpm "${HOME}/.local/share/tmux/plugins/tpm"
fi

###
# NEOVIM
###

# if we do not set those paths here, then all installed binaries
# that were installed using mise, cannot be found. We want to be able
# to rerun this script multiple times without errors
source "${HOME}/.path.d/40_go.sh"
source "${HOME}/.path.d/50_mise.bash"
source "${HOME}/.path.d/99_default.sh"
eval "$(mise hook-env)"

echo "Installing dependency packages"
desired=(curl git universal-ctags ninja-build gettext cmake unzip
	build-essential autoconf automake fontconfig python3-pip)
missing=()
check_dpkged "missing" "${desired[@]}"
if [[ "${#missing[@]}" -gt 0 ]]; then
	echo "(apt) installing ${missing[*]}"
	sudo apt-get -y update
	sudo apt-get -y install "${missing[@]}"
fi

echo "Compiling and installing neovim"
cd "${HOME}" || exit
mkdir -p "${HOME}/software/"
cd "${HOME}/software/" || exit
git clone --filter=tree:0 https://github.com/neovim/neovim neovim_src
cd neovim_src || exit
git checkout stable
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${HOME}/software/neovim"
make install

if ! rustup -V >/dev/null 2>&1; then
	echo "Installing rust"
	mise plugin install rust
	mise install rust@latest
	mise use -g rust@latest
	# install shell completions
	mkdir -p "${HOME}/.rust/shell"
	rustup completions bash >"${HOME}/.rust/shell/completion_rustup.bash"
	rustup completions bash cargo >"${HOME}/.rust/shell/completion_cargo.bash"
	rustup completions zsh >"${HOME}/.rust/shell/_rustup"
	rustup completions zsh cargo >"${HOME}/.rust/shell/_cargo"
fi

if ! tree-sitter -V >/dev/null 2>&1; then
	echo "Installing tree-sitter cli"
	cargo install tree-sitter-cli
fi

if ! grep -qs python ~/.config/mise/config.toml; then
	# install python with mise, to avoit cluttering the global installation with modules
	mise install python@latest
	mise use -g python@latest
fi

if ! python3 -c 'import pynvim;' >/dev/null 2>&1; then
	echo "Installing python neovim module"
	python3 -mpip install pynvim
fi

if ! nvr --version >/dev/null 2>&1; then
	echo "Installing neovim-remote"
	python3 -mpip install neovim-remote
fi
