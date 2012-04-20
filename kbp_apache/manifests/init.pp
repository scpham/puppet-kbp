# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apache
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache inherits apache {
  include kbp_munin::client::apache

  gen_ferm::rule {
    "HTTP connections":
      proto  => "tcp",
      dport  => "80",
      action => "ACCEPT";
    "HTTPS connections":
      proto  => "tcp",
      dport  => "443",
      action => "ACCEPT";
  }

  file {
    "/etc/apache2/mods-available/deflate.conf":
      content => template("kbp_apache/mods-available/deflate.conf"),
      require => Package["apache2"],
      notify => Exec["reload-apache2"];
    "/etc/apache2/conf.d/security":
      content => template("kbp_apache/conf.d/security"),
      require => Package["apache2"],
      notify => Exec["reload-apache2"];
  }

  gen_logrotate::rotate { "apache2":
    logs       => "/var/log/apache2/*.log",
    options    => ["weekly", "rotate 52", "missingok", "notifempty", "create 640 root adm", "compress", "delaycompress", "sharedscripts", "dateext"],
    postrotate => "/etc/init.d/apache2 reload > /dev/null",
    require    => Package["apache2"];
  }

  apache::module { "deflate":
    ensure => present,
  }

  kbp_icinga::http { "http_${fqdn}":; }
}

# Class: kbp_apache::passenger
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache::passenger {
  include kbp_apache
  include kbp_apache::ssl
  include kbp_icinga::passenger::queue

  package { "libapache2-mod-passenger":
    ensure => latest;
  }

  apache::module { "passenger":
    require => Package["libapache2-mod-passenger"],
  }
}

class kbp_apache::php {
  include kbp_apache
  include gen_base::libapache2-mod-php5
}

# Class: kbp_apache::ssl
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache::ssl {
  apache::module { "ssl":; }
}

# Define: kbp_apache::site
#
# Parameters:
#  priority
#    Undocumented
#  ensure
#    Undocumented
#  max_check_attempts
#    For overriding the default max_check_attempts of the service
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_apache::site($ensure="present", $priority="", $auth=false, $max_check_attempts=false, $monitor_path=false, $monitor_response=false,
    $monitor_probe=false, $monitor_check_interval=false, $monitor=true, $smokeping=true, $address=false, $address6=false, $ssl=false, $vhost=true) {
  $dontmonitor = ["default","default-ssl","localhost"]

  if $ensure == "present" and $monitor and ! ($name in $dontmonitor) {
    kbp_icinga::site { $name:
      max_check_attempts => $max_check_attempts ? {
        false   => undef,
        default => $max_check_attempts,
      },
      auth               => $auth ? {
        false   => undef,
        default => $auth,
      },
      path               => $monitor_path ? {
        false   => undef,
        default => $monitor_path,
      },
      response           => $monitor_response ? {
        false   => undef,
        default => $monitor_response,
      },
      check_interval     => $monitor_check_interval,
      address            => $address ? {
        false   => undef,
        default => $address,
      },
      ssl                => $address ? {
        false   => $ssl,
        default => true,
      },
      vhost              => $vhost;
    }

    if $smokeping {
      kbp_smokeping::target { "${name}":
        probe => $monitor_probe ? {
          false   => $auth ? {
            false => undef,
            true  => "FPing",
          },
          default => $monitor_probe,
        },
        path  => $monitor_path ? {
          false   => undef,
          default => $monitor_path,
        };
      }
    }
  }

  apache::site { "${name}":
    ensure   => $ensure,
    priority => $priority;
  }
}
