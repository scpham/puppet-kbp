alias kickpuppet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog'
alias kptim='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8150'
alias kprut='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8151'
alias kped='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8152'
alias kppiet='sudo puppetd --no-daemonize --no-splay --onetime --logdest console --logdest syslog --verbose --server testpuppetmaster.kumina.nl --masterport=8153'

if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi
