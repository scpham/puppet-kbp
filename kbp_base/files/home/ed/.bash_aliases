alias kickpuppet='sudo puppetd --verbose --no-daemonize --no-splay --onetime'
alias runpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'
alias kptim='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8150 --ca_server puppet.kumina.nl --ca_port 8140'
alias kprut='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8151 --ca_server puppet.kumina.nl --ca_port 8140'
alias kped='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8152 --ca_server puppet.kumina.nl --ca_port 8140'
alias kppiet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8153 --ca_server puppet.kumina.nl --ca_port 8140'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
