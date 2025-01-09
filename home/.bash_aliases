# my personal initialization script 1st part
[[ -f "${HOME}/.preinitialization.sh" ]] && source "${HOME}/.preinitialization.sh"

# shellcheck disable=SC2086
[[ -f "${HOME}/.oh-my-posh/posh.json" ]] && eval "$(oh-my-posh init bash --config ${HOME}/.oh-my-posh/posh.json)"

# my personal initialization script 2nd part
[[ -f "${HOME}/.postinitialization.sh" ]] && source "${HOME}/.postinitialization.sh"
