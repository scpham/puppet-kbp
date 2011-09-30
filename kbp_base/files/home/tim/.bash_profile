# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
umask 002

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi

EMAIL=tim@kumina.nl
export EMAIL

[ "$TERM" = "xterm" ] && export TERM=xterm-256color
[ "$TERM" = "screen" ] && export TERM=screen-256color

if [ `hostname` = "puppetmaster" ]; then
	export JAVA_HOME=/usr
	export AWS_RDS_HOME=/home/tim/RDSCli-1.4.007/
	export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/
	export AWS_CREDENTIAL_FILE=$AWS_RDS_HOME/credential-file-path.template
fi
