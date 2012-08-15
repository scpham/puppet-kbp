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
}

# Define: kbp_wordpress
#
# Actions:
#  Setup a wordpress instance.
#
# Parameters:
#  mysql_name
#   The name for the MySQL server.
#  db
#   The MySQL database
#  user
#   The MySQL user, defaults to $db.
#  password
#   The password for the MySQL user.
#
# Depends:
#  kbp_wordpress::common
#  kbp_apache_new
#  mysql
#
define kbp_wordpress($external_mysql = true, $mysql_name, $db = false, $user = $false, $password) {
  include kbp_wordpress::common

  $real_db = $db ? {
    false   => regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G'),
    default => $db,
  }
  $real_user = $user ? {
    false   => $real_db,
    default => $user,
  }

  kbp_apache_new::site { $name:
    php => true;
  }

  if $external_mysql {
    @@mysql::server::db { $real_db:
      tag => "mysql_${environment}_${mysql_name}";
    }

    @@mysql::server::grant { "${real_user} on ${real_db}.*":
      password   => $password,
      tag        => "mysql_${environment}_${mysql_name}";
    }
  } elsif ! defined(Class['kbp_mysql::server']) {
    class { 'kbp_mysql::server':
      mysql_name => $mysql_name;
    }

    mysql::server::db { $real_db:; }

    mysql::server::grant { "${real_user} on ${real_db}.*":
      password => $password;
    }
  }
}
