[ "$TERM" = "xterm" ] && export TERM=xterm-256color
[ "$TERM" = "screen" ] && export TERM=screen-256color

case "$TERM" in
*256color)
	NCOLORS=256
	;;
*)
	NCOLORS=`tput colors`
	;;
esac

if [ `id -u` = 0 ]; then
	if [ $NCOLORS = 256 ]; then
		export PS1="%{]0;(%m) %~ #%}%{[m%}(%{[38;5;196m%}%m%{[m%}) %{[38;5;81m%}%~ %{[m%}# "
	else
		export PS1="%{]0;(%m) %~ #%}%{[m%}(%{[1;31m%}%m%{[m%}) %{[1;34m%}%~ %{[m%}# "
	fi
	alias ls='/bin/ls -AF'
else
	if [ $NCOLORS = 256 ]; then
		export PS1="%{]0;(%n@%m) %~ $%}%{[m%}(%{[38;5;227m%}%n%{[m%}@%{[38;5;119m%}%m%{[m%}) %{[38;5;81m%}%~ %{[m%}$ "
	else
		export PS1="%{]0;(%n@%m) %~ $%}%{[m%}(%{[1;33m%}%n%{[m%}@%{[1;32m%}%m%{[m%}) %{[1;34m%}%~ %{[m%}$ "
	fi
	alias ls='/bin/ls -F'
fi

set -o vi

alias su='sudo su -'
alias sudo='sudo '
alias vi='vim'
alias sl='ls'
alias open='xdg-open'

export EDITOR='vim'
export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"

# Add local aliases
if test -f ~/.bash_aliases
then
	. ~/.bash_aliases
fi
