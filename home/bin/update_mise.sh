#!/bin/bash

get_os() {
	os="$(uname -s)"
	if [ "$os" = Darwin ]; then
		echo "macos"
	elif [ "$os" = Linux ]; then
		echo "linux"
	else
		error "unsupported OS: $os"
	fi
}

get_arch() {
	arch="$(uname -m)"
	if [ "$arch" = x86_64 ]; then
		echo "x64"
	elif [ "$arch" = aarch64 ] || [ "$arch" = arm64 ]; then
		echo "arm64"
	else
		error "unsupported architecture: $arch"
	fi
}

update_mise() {
	echo "Updating mise..."
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		brew install mise
		MISE=mise
	else
		arch="$(get_arch)"
		mkdir -p "${HOME}/bin"
		latest=$(curl -s https://api.github.com/repositories/586920414/tags | jq -r ".[0].name")
		echo "Latest release seems to be: ${latest}"
		if ! curl -sL "https://github.com/jdx/mise/releases/download/${latest}/mise-${latest}-${os}-${arch}" >"${HOME}/bin/mise"; then
			echo "Download failed. Aborting."
			exit 1
		fi
		chmod 755 "${HOME}/bin/mise"
		MISE="${HOME}/bin/mise"
	fi
	export MISE
	echo "done."
}

update_mise
