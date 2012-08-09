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
define kbp_wordpress($mysql_name, $db, $user = $db, $password) {
  include kbp_wordpress::common

  kbp_apache_new::site { $name:
    php => true;
  }

  if ! defined(Class['kbp_mysql::server']) {
    class { 'kbp_mysql::server':
      mysql_name => $mysql_name;
    }
  }

  mysql::server::db { $db:; }

  mysql::server::grant { "${user} on ${db}.*":
    password => $password;
  }
}
