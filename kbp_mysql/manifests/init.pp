# Author: Kumina bv <support@kumina.nl>

# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
class kbp_mysql::mastermaster($mysql_name, $bind_address="0.0.0.0", $setup_backup=true, $monitoring_ha_slaving=false, $repl_host=$fqdn, $datadir=false) {
  class { "kbp_mysql::master":
    mysql_name   => $mysql_name,
    bind_address => $bind_address,
    setup_backup => $setup_backup,
    datadir      => $datadir;
  }
  class { "kbp_mysql::slave":
    repl_host     => $repl_host,
    mysql_name    => $mysql_name,
    mastermaster  => true,
    monitoring_ha => $monitoring_ha_slaving,
    datadir       => $datadir;
  }
}

# Parameters:
#  mysql_name
#    The name of this MySQL setup, used in combination with $environment to make sure the correct resources are imported
class kbp_mysql::master($mysql_name, $bind_address="0.0.0.0", $setup_backup=true, $datadir=false) {
  class { "kbp_mysql::server":
    mysql_name   => $mysql_name,
    setup_backup => $setup_backup,
    bind_address => $bind_address,
    datadir      => $datadir;
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
class kbp_mysql::slave($mysql_name, $bind_address="0.0.0.0", $mastermaster=false, $setup_backup=true, $monitoring_ha=false, $repl_host=$fqdn, $datadir=false, $repl_user='repl', $repl_password='etohsh8xahNu', $repl_require_ssl=false) {
  if ! $mastermaster {
    class { "kbp_mysql::server":
      mysql_name   => $mysql_name,
      setup_backup => $setup_backup,
      bind_address => $bind_address,
      datadir      => $datadir;
    }
  }

  @@mysql::server::grant { "repl_${fqdn}":
    user        => $repl_user,
    password    => $repl_password,
    hostname    => $repl_host,
    db          => '*',
    permissions => "replication slave",
    require_ssl => $repl_require_ssl,
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
    ha                  => $monitoring_ha,
    check_interval      => 60;
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
class kbp_mysql::server($mysql_name, $bind_address="0.0.0.0", $setup_backup=true, $datadir=false, $charset=false) {
  include kbp_trending::mysql
  include kbp_mysql::monitoring::icinga::server
  class { "mysql::server":
    datadir => $datadir;
  }

  if $setup_backup {
    file { "/etc/backup/prepare.d/mysql":
      ensure  => link,
      target  => "/usr/share/backup-scripts/prepare/mysql",
      require => Package["backup-scripts"];
    }

    file { "/etc/mysql/conf.d/expire_logs.cnf":
      content => "[mysqld]\nexpire_logs_days = 7\n";
    }
  }

  file {
    "/etc/mysql/conf.d/bind-address.cnf":
      content => "[mysqld]\nbind-address = ${bind_address}\n",
      notify  => Service["mysql"];
    "/etc/mysql/conf.d/character-set-server.cnf":
      ensure  => absent;
#      content => "[mysqld]\ncharacter-set-server = 'utf8'\n",
#      notify  => Service["mysql"];
  }

  kbp_backup::exclude { "exclude_var_lib_mysql":
    content => "/var/lib/mysql/*";
  }

  exec { 'remove_root_users':
    onlyif  => '/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e "select * from mysql.user where user=\'root\' and password=\'\'" | /bin/grep -q root',
    command => '/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e "delete from mysql.user where user=\'root\'; flush privileges"',
    require => Service["mysql"];
  }

  Kbp_ferm::Rule <<| tag == "mysql_${environment}_${mysql_name}" |>>

  Gen_ferm::Rule <<| tag == "mysql_monitoring" |>>
}

# Class: kbp_mysql::server::ssl
#
# Parameters:
#  cert_dir
#    The directory where the cert, cacert and serverkey are located.
#
# Actions:
#  Activate the ability to connect over SSL to the MySQL server
#
# Depends:
#  kbp_mysql::server
#  gen_puppet
#
class kbp_mysql::server::ssl ($certname=$fqdn, $intermediate){
  file { "/etc/mysql/conf.d/ssl.cnf":
    content  => "[mysqld]\nssl\nssl-ca=/etc/ssl/certs/${intermediate}.pem\nssl-cert=/etc/ssl/certs/${certname}.pem\nssl-key=/etc/ssl/private/${certname}.key",
    require => File["/etc/ssl/certs/${intermediate}.pem", "/etc/ssl/certs/${certname}.pem", "/etc/ssl/private/${certname}.key"],
    notify  => Exec['reload-mysql'];
  }

  setfacl { "Allow MySQL read access to /etc/ssl/private":
    dir     => '/etc/ssl/private',
    recurse => false,
    acl     => 'user:mysql:--x';
  }
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
  kbp_icinga::service {
    "mysql":
      service_description => "MySQL service",
      check_command       => "check_mysql",
      nrpe                => true;
    "mysql_connlimit":
      service_description => "MySQL service connection limit",
      check_command       => "check_mysql_connlimit",
      nrpe                => true;
  }

  mysql::user { "monitoring":
    user => "nagios";
  }
}

class kbp_mysql::client::java {
  include mysql::java
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
define kbp_mysql::client ($mysql_name, $address=$source_ipaddress, $environment=$environment) {
  include gen_base::mysql_client

  kbp_ferm::rule { "MySQL connections for ${name}":
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
