# Author: Kumina bv <support@kumina.nl>

# Class: kbp_postfix
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_postfix($relayhost=false, $myhostname=$fqdn, $mynetworks="127.0.0.0/8 [::1]/128", $mydestination=false, $mode=false, $mailname=false, $active=false, $incoming=false) {
  if $active {
  class { "postfix":
    relayhost     => $relayhost,
    myhostname    => $myhostname,
    mynetworks    => $mynetworks,
    mydestination => $mydestination,
    mode          => $mode;
  }
  include munin::client
  include kbp_openssl::common

  $real_mailname = $mailname ? {
    false   => $fqdn,
    default => $mailname,
  }

  line {
    "root: reports+${environment}@kumina.nl":
      file => "/etc/aliases";
    "reports: root":
      file => "/etc/aliases";
  }

  kfile { "/etc/mailname":
    content => "${real_mailname}\n",
    notify  => Service["postfix"],
    require => Package["postfix"];
  }

  munin::client::plugin { ["postfix_mailqueue", "postfix_mailstats", "postfix_mailvolume"]:; }

  munin::client::plugin { ["exim_mailstats"]:
    ensure => absent;
  }

  if $incoming or mode == "primary" or mode == "secondary" {
    gen_ferm::rule { "SMTP connections":
      proto  => "tcp",
      dport  => "(25 465)",
      action => "ACCEPT";
    }
  }
  }
}
