# Author: Kumina bv <support@kumina.nl>

class kbp_postfix::mailgraph {
  include gen_base::mailgraph
}

# Class: kbp_postfix
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_postfix($certs=false, $relayhost=false, $mailname=false, $myhostname=false, $mynetworks=false, $mydestination=false, $mode=false,
    $mailname=$fqdn, $incoming=false, $always_bcc=false, $mysql_user=false, $mysql_pass=false, $mysql_db=false, $mysql_host=false,
    $relay_domains=false) {
  include kbp_openssl::common
  class { 'gen_postfix':
    certs         => $certs,
    relayhost     => $relayhost,
    myhostname    => $myhostname,
    mynetworks    => $mynetworks,
    mydestination => $mydestination,
    mode          => $mode,
    always_bcc    => $always_bcc,
    mysql_user    => $mysql_user,
    mysql_pass    => $mysql_pass,
    mysql_db      => $mysql_db,
    mysql_host    => $mysql_host,
    relay_domains => $relay_domains;
  }
  if $mode == 'primary' {
    include gen_base::postfix_mysql
    if ! $certs {
      fail('When using primary mode for kbp_postfix, $certs must be set')
    }
  }

  gen_postfix::alias { ["root: reports+${environment}@kumina.nl",'reports: root']:; }

  file { '/etc/mailname':
    content => $mailname ? {
      false   => "${fqdn}\n",
      default => "${mailname}\n",
    },
    notify  => Exec['reload-postfix'];
  }

  exec { "postmap blocked_domains":
    command     => "/usr/sbin/postmap /etc/postfix/blocked_domains",
    refreshonly => true;
  }

  gen_munin::client::plugin {
    ['postfix_mailqueue', 'postfix_mailstats', 'postfix_mailvolume']:;
    ['exim_mailstats']:
      ensure => absent;
  }
}
