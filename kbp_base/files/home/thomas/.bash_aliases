alias kickpuppet='sudo puppet agent --verbose --no-daemonize --no-splay --onetime --usecacheonfailure false --ignorecache true --server puppetmaster.kumina.nl'
alias kptim='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'
alias kprut='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8151 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'
alias kped='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8152 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'
alias kppiet='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8153 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'
alias kpthom='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8154 --ca_server puppet.kumina.nl --ca_port 8140 --usecacheonfailure false --ignorecache true'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
