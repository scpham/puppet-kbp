# Author: Kumina bv <support@kumina.nl>

# Class: kbp_wordpress::common
#
# Actions:
#  Setup the resources needed for Wordpress that do not require parameters.
#
# Depends:
#  gen_php5::mysql
#  gen_php5::gd
#  gen_php5::curl
#
class kbp_wordpress::common {
  include gen_php5::mysql
  include gen_php5::gd
  include gen_php5::curl

  file { '/usr/local/bin/fix_wp_permissions':
    content => template('kbp_wordpress/fix_wp_permissions.sh'),
    mode    => 755;
  }
}

# Define: kbp_wordpress
#
# Actions:
#  Setup a wordpress instance.
#
# Parameters:
#  mysql_tag
#   The name for the MySQL server.
#  db
#   The MySQL database
#  user
#   The MySQL user, defaults to $db.
#  password
#   The password for the MySQL user.
#  serveralias
#   Serveralias for this vhost. Can be an array.
#  access_logformat
#   The format to use for the log. Defaults to combined.
#  monitoring_url
#   The path to use for the monitoring. Defaults to '/'.
#
# Depends:
#  kbp_wordpress::common
#  kbp_apache
#  mysql
#
define kbp_wordpress($external_mysql=true, $mysql_tag=false, $db=false, $user=false, $password, $serveralias=false, $access_logformat="combined", $monitoring_url='/', $address='*') {
  include kbp_wordpress::common

  $real_tag = $mysql_tag ? {
    false   => "mysql_${environment}_${custenv}",
    default => "mysql_${environment}_${custenv}_${mysql_tag}",
  }
  $real_db = $db ? {
    false   => regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G'),
    default => $db,
  }
  $real_user = $user ? {
    false   => $real_db,
    default => $user,
  }

  kbp_apache::site { $name:
    serveralias      => $serveralias,
    access_logformat => $access_logformat,
    monitor_path     => $monitoring_url,
    php              => true,
    address          => $address;
  }

  if $external_mysql {
    @@mysql::server::grant { "${real_user} on ${real_db}.*":
      password   => $password,
      tag        => $real_tag;
    }
  } else {
    if ! defined(Class['kbp_mysql::server']) {
      class { 'kbp_mysql::server':
        mysql_tag => $mysql_tag;
      }
    }

    mysql::server::grant { "${real_user} on ${real_db}.*":
      password => $password;
    }
  }
}
