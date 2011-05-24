alias kickpuppet='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog'
alias kptim='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8140'
alias kprut='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8151 --ca_server puppet.kumina.nl --ca_port 8140'
alias kped='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8152 --ca_server puppet.kumina.nl --ca_port 8140'
alias kppiet='sudo puppet agent --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8153 --ca_server puppet.kumina.nl --ca_port 8140'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
