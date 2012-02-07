# Author: Kumina bv <support@kumina.nl>

# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
class kbp_mysql::mastermaster($mysql_name, $bind_address="0.0.0.0", $setup_backup=true, $monitoring_ha_slaving=false, $repl_host=$fqdn) {
  class { "kbp_mysql::master":
    mysql_name   => $mysql_name,
    bind_address => $bind_address,
    setup_backup => $setup_backup;
  }
  class { "kbp_mysql::slave":
    repl_host     => $repl_host,
    mysql_name    => $mysql_name,
    mastermaster  => true,
    monitoring_ha => $monitoring_ha_slaving;
  }
}

# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
class kbp_mysql::master($mysql_name, $bind_address="0.0.0.0", $setup_backup=true) {
  class { "kbp_mysql::server":
    mysql_name   => $mysql_name,
    setup_backup => $setup_backup,
    bind_address => $bind_address;
  }

  Mysql::Server::Grant <<| tag == "mysql_${environment}_${mysql_name}" |>>
  Kbp_mysql::Monitoring_dependency <<| tag == "mysql_${environment}_${mysql_name}" |>>

  if ! defined(Kbp_mysql::Monitoring_dependency["mysql_${environment}_${mysql_name}_${fqdn}"]) {
    @@kbp_mysql::monitoring_dependency { "mysql_${environment}_${mysql_name}_${fqdn}":; }
  }
}

# Class: kbp_mysql::slave
#
# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mysql::slave($mysql_name, $bind_address="0.0.0.0", $mastermaster=false, $setup_backup=true, $monitoring_ha=false, $repl_host=$fqdn) {
  if ! $mastermaster {
    class { "kbp_mysql::server":
      mysql_name   => $mysql_name,
      setup_backup => $setup_backup,
      bind_address => $bind_address;
    }
  }

  @@mysql::server::grant { "repl_${fqdn}":
    user        => "repl",
    password    => "etohsh8xahNu",
    hostname    => $repl_host,
    db          => "*",
    permissions => "replication slave",
    tag         => "mysql_${environment}_${mysql_name}";
  }

  mysql::server::grant { "nagios_slavecheck":
    user        => "nagios",
    db          => "*",
    permissions => "super, replication client";
  }

  kbp_ferm::rule { "MySQL slaving from ${fqdn}":
    exported => true,
    saddr    => $repl_host,
    proto    => "tcp",
    dport    => 3306,
    action   => "ACCEPT",
    ferm_tag => "mysql_${environment}_${mysql_name}";
  }

  kbp_icinga::service { "mysql_slaving":
    service_description => "MySQL slaving",
    check_command       => "check_mysql_slave",
    nrpe                => true,
    ha                  => $monitoring_ha;
  }
}

# Class: kbp_mysql::server
#
# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mysql::server($mysql_name, $bind_address="0.0.0.0", $setup_backup=false) {
  include mysql::server
  include kbp_trending::mysql
  include kbp_mysql::monitoring::icinga::server

  if $setup_backup {
    kfile { "/etc/mysql/conf.d/expire_logs.cnf":
      content => "[mysqld]\nexpire_logs_days = 7\n",
      notify  => Exec["reload-mysql"];
    }
  }

  kfile { "/etc/mysql/conf.d/bind-address.cnf":
    content => "[mysqld]\nbind-address = ${bind_address}\n",
    notify  => Service["mysql"];
  }

  kfile { "/etc/backup/prepare.d/mysql":
    ensure  => link,
    target  => "/usr/share/backup-scripts/prepare/mysql",
    require => Kpackage["backup-scripts"];
  }

  kbp_backup::exclude { "exclude_var_lib_mysql":
    content => "/var/lib/mysql/*";
  }

  Kbp_ferm::Rule <<| tag == "mysql_${environment}_${mysql_name}" |>>

  Gen_ferm::Rule <<| tag == "mysql_monitoring" |>>
}

# Class: kbp_mysql::monitoring::icinga::server
#
# Parameters:
#  otherhost
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mysql::monitoring::icinga::server($otherhost=false) {
  kbp_icinga::service { "mysql":
    service_description => "MySQL service",
    check_command       => "check_mysql",
    nrpe                => true;
  }

  mysql::user { "monitoring":
    user => "nagios";
  }
}

class kbp_mysql::client::java {
  include mysql::java
}

# Class: kbp_mysql::puppetmaster
#
# Actions:
#  Setup a database and user for the puppetmaster, as requested.
#
# Depends:
#  gen_puppet
#  kbp_mysql::server
#
class kbp_mysql::puppetmaster {
  class { "kbp_mysql::server":
    mysql_name => "puppetmaster";
  }

  Kbp_ferm::Rule       <<| tag == "mysql_${environment}_puppetmaster" |>>
  Mysql::Server::Db    <<| tag == "${environment}_puppetmaster" |>>
  Mysql::Server::Grant <<| tag == "${environment}_puppetmaster" |>>
}

# Define: kbp_mysql::client
#
# Parameters:
#  mysql_name
#    The name of the service that's using MySQL
#
# Actions:
#  Open the firewall on the server to allow access from this client.
#  Make sure the title of the resource is something sane, since if you
#  use "dummy" everywhere, it still clashes.
#
# Depends:
#  kbp_ferm
#  gen_puppet
#
define kbp_mysql::client ($mysql_name, $address=$fqdn) {
  include gen_base::mysql_client

  kbp_ferm::rule { "MySQL connections from ${fqdn} for ${name}":
    exported => true,
    saddr    => $address,
    proto    => "tcp",
    dport    => 3306,
    action   => "ACCEPT",
    ferm_tag => "mysql_${environment}_${mysql_name}";
  }
}

define kbp_mysql::monitoring_dependency($this_fqdn=$fqdn) {
  if $this_fqdn != $fqdn {
    gen_icinga::servicedependency { "mysql_dependency_${fqdn}":
      dependent_service_description => "MySQL service",
      host_name                     => $this_fqdn,
      service_description           => "MySQL service",
      tag                           => "mysql_${environment}_${mysql_name}";
    }
  }
}
