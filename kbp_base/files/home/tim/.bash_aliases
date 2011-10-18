alias kickpuppet='sudo puppet agent --no-daemonize --no-splay --onetime --usecacheonfailure false --ignorecache true'
alias kptim='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --server testpuppetmaster.kumina.nl --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'
alias gitpull='git pull --rebase'
alias mysqldeb='sudo mysql --defaults-file=/etc/mysql/debian.cnf'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
