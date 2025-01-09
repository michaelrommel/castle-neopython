#! /usr/bin/env bash

# if [[ -d "${HOME}/.cargo/bin" && ! ":${PATH}:" == *:${HOME}/.cargo/bin:* ]]; then
# 	# path has not yet been added
# 	export PATH="${HOME}/.cargo/bin:${PATH}"
# fi

# Auto-completion
# ---------------
if [[ $- == *i* && -d "${HOME}/.rust/shell" ]]; then
	source "${HOME}/.rust/shell/completion_rustup.bash" 2>/dev/null
	source "${HOME}/.rust/shell/completion_cargo.bash" 2>/dev/null
fi
