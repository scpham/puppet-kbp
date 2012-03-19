alias kickpuppet='sudo puppet agent --verbose --no-daemonize --no-splay --onetime --no-usecacheonfailure --ignorecache --server puppet1.kumina.nl --ca_server puppet1.kumina.nl --ca_port 8141'
alias kptim='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server puppet1.kumina.nl --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8141 --no-usecacheonfailure --ignorecache'
alias kprut='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server puppet1.kumina.nl --masterport=8151 --ca_server puppet1.kumina.nl --ca_port 8141 --no-usecacheonfailure --ignorecache'
alias kppiet='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server puppet1.kumina.nl --masterport=8153 --ca_server puppet1.kumina.nl --ca_port 8141 --no-usecacheonfailure --ignorecache'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
