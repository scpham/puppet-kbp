# Author: Kumina bv <support@kumina.nl>

class kbp_mysql::mastermaster($mysql_name, $setup_backup=true, $monitoring_ha_slaving=false) {
  class { "kbp_mysql::master":
    mysql_name   => $mysql_name,
    setup_backup => $setup_backup;
  }
  class { "kbp_mysql::slave":
    mysql_name    => $mysql_name,
    setup_backup  => $setup_backup,
    monitoring_ha => $monitoring_ha_slaving;
  }

  Kbp_mysql::Monitoring_dependency <<| tag == "mysql_${environment}_${mysql_name}" |>>

  if ! defined(Kbp_mysql::Monitoring_dependency["mysql_${environment}_${mysql_name}_${fqdn}"]) {
    @@kbp_mysql::monitoring_dependency { "mysql_${environment}_${mysql_name}_${fqdn}":; }
  }
}

class kbp_mysql::master($mysql_name, $setup_backup=true) {
  include kbp_mysql::server

  Gen_ferm::Rule <<| tag == "mysql_${environment}_${mysql_name}" |>>

  Mysql::Server::Grant <<| tag == "mysql_${environment}_${mysql_name}" |>>
  Kbp_mysql::Monitoring_dependency <<| tag == "mysql_${environment}_${mysql_name}" |>>

  if ! defined(Kbp_mysql::Monitoring_dependency["mysql_${environment}_${mysql_name}_${fqdn}"]) {
    @@kbp_mysql::monitoring_dependency { "mysql_${environment}_${mysql_name}_${fqdn}":; }
  }

  Kfile <| title == "/etc/mysql/conf.d/expire_logs.cnf" |> {
    ensure => $setup_backup ? {
      true  => "present",
      false => "absent",
    },
  }
}

# Class: kbp_mysql::slave
#
# Parameters:
#  customtag
#    Undocumented
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
class kbp_mysql::slave($mysql_name, $setup_backup=true, $monitoring_ha=false) {
  include kbp_mysql::server

  Gen_ferm::Rule <<| tag == "mysql_${environment}_${mysql_name}" |>>

  @@mysql::server::grant { "repl_${fqdn}":
    user        => "repl",
    password    => "etohsh8xahNu",
    hostname    => $fqdn,
    db          => "*",
    permissions => "replication slave",
    tag         => "mysql_${environment}_${mysql_name}";
  }

  mysql::server::grant { "nagios_slavecheck":
    user        => "nagios",
    db          => "*",
    permissions => "super, replication client";
  }

  @@gen_ferm::rule { "MySQL slaving from ${fqdn}":
    saddr  => $fqdn,
    proto  => "tcp",
    dport  => 3306,
    action => "ACCEPT",
    tag    => "mysql_${environment}_${mysql_name}";
  }

  kbp_icinga::service { "mysql_slaving":
    service_description => "MySQL slaving",
    check_command       => "check_mysql_slave",
    nrpe                => true,
    ha                  => $monitoring_ha;
  }

  Kfile <| title == "/etc/mysql/conf.d/expire_logs.cnf" |> {
    ensure => $setup_backup ? {
      true  => "present",
      false => "absent",
    },
  }
}

class kbp_mysql::standalone($mysql_name, $setup_backup=false) {
  include kbp_mysql::server

  Gen_ferm::Rule <<| tag == "mysql_${environment}_${mysql_name}" |>>

  Kfile <| title == "/etc/mysql/conf.d/expire_logs.cnf" |> {
    ensure => $setup_backup ? {
      true  => "present",
      false => "absent",
    },
  }
}

# Class: kbp_mysql::server
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
class kbp_mysql::server {
  include mysql::server
  include kbp_trending::mysql
  include kbp_mysql::monitoring::icinga::server

  kfile { "/etc/mysql/conf.d/expire_logs.cnf":
    content => "[mysqld]\nexpire_logs_days = 7\n",
    notify  => Exec["reload-mysql"];
  }

  if defined(Package["offsite-backup"]) {
    kfile { "/etc/backup/prepare.d/mysql":
      ensure  => link,
      target  => "/usr/share/backup-scripts/prepare/mysql",
      require => Package["offsite-backup"];
    }
  } elsif defined(Package["local-backup"]) {
    kfile { "/etc/backup/prepare.d/mysql":
      ensure => link,
      target  => "/usr/share/backup-scripts/prepare/mysql",
      require => Package["local-backup"];
    }
  }

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
  class { "kbp_mysql::standalone":
    mysql_name => "puppetmaster";
  }

  Gen_ferm::Rule <<| tag == "mysql_puppetmaster" |>>
  Mysql::Server::Db <<| tag == "mysql_puppetmaster" |>>
  Mysql::Server::Grant <<| tag == "mysql_puppetmaster" |>>
}

# Define: kbp_mysql::client
#
# Parameters:
#  customtag
#    Use a different tag than the default "mysql_${environment}"
#
# Actions:
#  Open the firewall on the server to allow access from this client.
#  Make sure the title of the resource is something sane, since if you
#  use "dummy" everywhere, it still clashes.
#
# Depends:
#  gen_ferm
#  gen_puppet
#
define kbp_mysql::client ($mysql_name=false, $address=$fqdn) {
  @@gen_ferm::rule { "MySQL connections from ${fqdn} for ${name}":
    saddr  => $address,
    proto  => "tcp",
    dport  => 3306,
    action => "ACCEPT",
    tag    => "mysql_${environment}_${mysql_name}";
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
