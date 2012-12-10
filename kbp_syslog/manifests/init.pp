# Author: Kumina bv <support@kumina.nl>

define kbp_syslog($client=true, $environmentonly=true) {
  if $client {
    kbp_syslog::client { $name:; }
  } else {
    kbp_syslog::server { $name:
      environmentonly => $environmentonly;
    }
  }
}

# Class: kbp_syslog::server::lenny
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::server::lenny inherits rsyslog::server {
  include kbp_syslog::server::logrotate

  gen_apt::preferences { 'rsyslog':; }
}

# Class: kbp_syslog::server::squeeze
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::server::squeeze inherits rsyslog::server {
  include kbp_syslog::server::logrotate
}

# Class: kbp_syslog::server::logrotate
#
# Action:
#  Setup logrotation to our defaults for syslog and companions.
#
# Depends:
#  gen_logrotate::rotate
#  gen_puppet
#
class kbp_syslog::server::logrotate {
  gen_logrotate::rotate { "rsyslog":
    logs       => ["/var/log/syslog", "/var/log/mail.info", "/var/log/mail.warn", "/var/log/mail.err", "/var/log/mail.log", "/var/log/daemon.log",
      "/var/log/kern.log", "/var/log/auth.log", "/var/log/user.log", "/var/log/lpr.log", "/var/log/cron.log", "/var/log/debug",
      "/var/log/messages","/var/log/external/*/syslog.log"],
    options    => ["daily", "rotate 90", "missingok", "notifempty", "compress", "delaycompress", "sharedscripts", "dateext"],
    postrotate => "invoke-rc.d rsyslog reload > /dev/null";
  }

  # TODO
  # Don't think this is needed anymore. Check after 2012-3-12 if there are still files like
  # syslog.3.gz on servers. If so, find another solution for this.
  #include kbp_syslog::cleanup
}

# Additional options
# Class: kbp_syslog::server::mysql
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::server::mysql {
  include kbp_syslog::server
  include "kbp_syslog::mysql::$lsbdistcodename"
}

# Class: kbp_syslog::mysql::etch
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::mysql::etch {
  err ("This is not implemented for Etch or earlier!")
}

# Class: kbp_syslog::mysql::lenny
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::mysql::lenny inherits rsyslog::mysql {
}

# Class: kbp_syslog::mysql::squeeze
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::mysql::squeeze inherits rsyslog::mysql {
}

# Define: kbp_syslog::server
#
# Actions:
#  Setup an rsyslog server that listens for incoming syslog traffic for clients that use the same tag as himself.
#
# Parameters:
#  name
#    A dummy, not used for anything.
#  environmentonly
#    Whether this server should receive data from all systems or only from it's own environment.
#  custom_tag
#    Override the tag to use. This setting overrides environmentonly (because that doesn't make sense then).
#
# Depends:
#  kbp_ferm
#  gen_puppet
#
define kbp_syslog::server($environmentonly=true,$custom_tag=false) {
  include "kbp_syslog::server::${lsbdistcodename}"

  if $custom_tag {
    $real_tag = $custom_tag
  } else {
    $real_tag = "syslog"
  }

  concat { '/etc/rsyslog.d/zz-allowed-peers.conf':
    require => Package['rsyslog'],
    notify  => Service['rsyslog'],
  }

  Kbp_ferm::Rule <<| tag == $real_tag |>>
  Concat::Add_content <<| tag == "${real_tag}_client" |>>

  @@concat::add_content { "allow syslog server ${fqdn}":
    content => template('rsyslog/client/zz-allowed-server.conf'),
    target  => '/etc/rsyslog.d/allowed-server.conf',
    tag     => "${real_tag}_server",
  }

  file { '/etc/rsyslog.d/zz-allowed-peers.conf':
    ensure => absent,
  }
}

# Define: kbp_syslog::client
#
# Actions:
#  Send local syslog data to a remote server.
#
# Paramters:
#  name: A dummy, not used for anything.
#  custom_tag: Override the tag to use.
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_syslog::client ($custom_tag=false) {
  include rsyslog::client

  if $custom_tag {
    $real_tag = $custom_tag
  } else {
    $real_tag = "syslog"
  }

  kbp_ferm::rule { "Syslog traffic (${name})":
    saddr    => $source_ipaddress,
    proto    => 'tcp',
    dport    => 10514,
    action   => "ACCEPT",
    exported => true,
    ferm_tag => $real_tag;
  }

  @@concat::add_content { "allow syslog access for ${fqdn}":
    content => template('rsyslog/server/allow-peer.conf'),
    target  => '/etc/rsyslog.d/zz-allowed-peers.conf',
    tag     => "${real_tag}_client";
  }

  concat { '/etc/rsyslog.d/zz-allowed-server.conf':
    require => Package['rsyslog'],
    notify  => Service['rsyslog'],
  }

  file { '/etc/rsyslog.d/allowed-server.conf':
    ensure => absent,
  }

  Concat::Add_content <<| tag == "${real_tag}_server" |>>
}
