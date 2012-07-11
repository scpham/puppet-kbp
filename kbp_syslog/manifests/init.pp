# Author: Kumina bv <support@kumina.nl>

define kbp_syslog($client=true, $environmentonly=true) {
  if $client {
    include kbp_syslog::client
  } else {
    class { "kbp_syslog::server":
      environmentonly => $environmentonly;
    }
  }
}

# Class: kbp_syslog::server
#
# Parameters:
#  environmentonly
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::server($environmentonly=true) {
  include "kbp_syslog::server::${lsbdistcodename}"

  if $environmentonly {
    Kbp_ferm::Rule <<| tag == "syslog_${environment}" |>>
  } else {
    Kbp_ferm::Rule <<| tag == "syslog" |>>
  }
}

# Class: kbp_syslog::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_syslog::client inherits rsyslog::client {
  kbp_ferm::rule { "Syslog traffic":
    saddr    => $source_ipaddress,
    proto    => "udp",
    dport    => 514,
    action   => "ACCEPT",
    exported => true,
    ferm_tag => ["syslog","syslog_${environment}"];
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
      "/var/log/messages"],
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

# Class: kbp_syslog::cleanup
#
# Actions:
#  Cleans up old syslog files. This class is a temporary workaround.
#
# Depends:
#  gen_puppet
#
class kbp_syslog::cleanup {
  $numbers = ["90","89","88","87","86","85","84","83","82","81","80","79","78","77","76","75","74","73","72","71","70",
              "69","68","67","66","65","64","63","62","61","60","59","58","57","56","55","54","53","52","51","50","49",
              "48","47","46","45","44","43","42","41","40","39","38","37","36","35","34","33","32","31","30","29","28",
        "27","26","25","24","23","22","21","20","19","18","17","16","15","14","13","12","11","10", "9", "8", "7",
         "6", "5", "4", "3", "2", "1", "0"]

  cleanup { $numbers:; }

  define cleanup {
    $files = ["syslog.${name}","mail.info.${name}","mail.warn.${name}","mail.err.${name}","mail.log.${name}",
        "daemon.log.${name}","kern.log.${name}","auth.log.${name}","user.log.${name}","lpr.log.${name}",
        "cron.log.${name}","debug.log.${name}","messages.${name}"]

    cleanup0 { $files:; }
  }

  define cleanup0 {
    $base = "/var/log/"
    file { ["${base}/${name}","${base}/${name}.gz"]:
      ensure => absent,
    }
  }
}
