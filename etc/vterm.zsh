#
# vterm (https://github.com/akermu/emacs-libvterm) integration
# TODO: replace this with elpa/vterm-.../etc/emacs-vterm-zsh.sh
#

# https://github.com/akermu/emacs-libvterm#shell-side-configuration
vterm_printf() {
  if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
    # Tell tmux to pass the escape sequences through
    printf "\ePtmux;\e\e]%s\007\e\\" "$1"
  elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf "\eP\e]%s\007\e\\" "$1"
  else
    printf "\e]%s\e\\" "$1"
  fi
}

# https://github.com/akermu/emacs-libvterm#vterm-clear-scrollback
alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'

# https://github.com/akermu/emacs-libvterm#directory-tracking-and-prompt-tracking
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

# https://github.com/akermu/emacs-libvterm/#vterm-buffer-name-string
autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd (){ print -Pn "\e]2;%2~\a" }
