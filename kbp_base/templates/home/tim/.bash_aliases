alias kickpuppet='sudo puppet agent --no-daemonize --no-splay --onetime --no-usecacheonfailure --ignorecache --logdest console --logdest syslog --ca_server puppet.kumina.nl --ca_port 8141 '
alias kptim='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8141 --no-usecacheonfailure --ignorecache'
alias gitpull='git pull --rebase'
alias mysqldeb='sudo mysql --defaults-file=/etc/mysql/debian.cnf'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
