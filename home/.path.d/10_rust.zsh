#! /usr/bib/env zsh

# if [[ -d "${HOME}/.cargo/bin" && ! ":${PATH}:" == *:${HOME}/.cargo/bin:* ]]; then
# 	# path has not yet been added
# 	export PATH="${HOME}/.cargo/bin:${PATH}"
# fi

# Auto-completion
# ---------------
if [[ $- == *i* && -d "${HOME}/.rust/shell" ]]; then
	fpath=(${HOME}/.rust/shell $fpath)
fi
