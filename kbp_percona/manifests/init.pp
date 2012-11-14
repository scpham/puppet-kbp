# Author: Kumina bv <support@kumina.nl>

# Parameters:
#  percona_name         The name of this Percona setup, used in combination with $environment to make sure the correct resources are imported
#  slow_query_time    See kbp_percona::server
#
class kbp_percona::mastermaster($percona_name, $repl_password, $repl_user='repl', $bind_address="0.0.0.0", $setup_backup=true, $monitoring_ha_slaving=false, $repl_host=$source_ipaddress, $datadir=false, $slow_query_time=10) {
  class { "kbp_percona::master":
    percona_name      => $percona_name,
    bind_address    => $bind_address,
    setup_backup    => $setup_backup,
    datadir         => $datadir,
    slow_query_time => $slow_query_time;
  }
  class { "kbp_percona::slave":
    repl_host       => $repl_host,
    percona_name      => $percona_name,
    mastermaster    => true,
    monitoring_ha   => $monitoring_ha_slaving,
    datadir         => $datadir,
    slow_query_time => $slow_query_time,
    repl_user       => $repl_user,
    repl_password   => $repl_password;
  }
  fail("This class is untested and simply a copy from kbp_mysql.")
}

# Parameters:
#  percona_name       The name of this Percona setup, used in combination with $environment to make sure the correct resources are imported
#  slow_query_time    See kbp_percona::server
#
class kbp_percona::master($percona_name, $bind_address="0.0.0.0", $setup_backup=true, $datadir=false, $slow_query_time=10, $percona_version=false) {
  class { "kbp_percona::server":
    percona_name    => $percona_name,
    percona_version => $percona_version,
    setup_backup    => $setup_backup,
    bind_address    => $bind_address,
    datadir         => $datadir,
    slow_query_time => $slow_query_time;
  }

  Gen_percona::Server::Grant <<| tag == "percona_${environment}_${percona_name}" |>>
  Kbp_percona::Monitoring_dependency <<| tag == "percona_${environment}_${percona_name}" |>>

  if ! defined(Kbp_percona::Monitoring_dependency["percona_${environment}_${percona_name}_${fqdn}"]) {
    @@kbp_percona::monitoring_dependency { "percona_${environment}_${percona_name}_${fqdn}":; }
  }
}

# Class: kbp_percona::slave
#
# Parameters:
#  percona_name         The name of this Percona setup, used in combination with $environment to make sure the correct resources are imported
#  slow_query_time    See kbp_percona::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_percona::slave($percona_name, $bind_address="0.0.0.0", $mastermaster=false, $setup_backup=true, $monitoring_ha=false, $repl_host=$source_ipaddress, $datadir=false, $repl_user='repl', $repl_password, $repl_require_ssl=false, $slow_query_time=10) {
  if ! $mastermaster {
    class { "kbp_percona::server":
      percona_name      => $percona_name,
      setup_backup    => $setup_backup,
      bind_address    => $bind_address,
      datadir         => $datadir,
      slow_query_time => $slow_query_time;
    }
  }

  @@percona::server::grant { "repl_${fqdn}":
    user        => $repl_user,
    password    => $repl_password,
    hostname    => $repl_host,
    db          => '*',
    permissions => "replication slave",
    require_ssl => $repl_require_ssl,
    tag         => "percona_${environment}_${percona_name}";
  }

  percona::server::grant { "nagios_slavecheck":
    user        => "nagios",
    db          => "*",
    permissions => "super, replication client";
  }

  kbp_ferm::rule { "Percona slaving":
    exported => true,
    saddr    => $repl_host,
    proto    => "tcp",
    dport    => 3306,
    action   => "ACCEPT",
    ferm_tag => "percona_${environment}_${percona_name}";
  }

  kbp_icinga::service { "percona_slaving":
    service_description => "Percona slaving",
    check_command       => "check_percona_slave",
    nrpe                => true,
    ha                  => $monitoring_ha,
    check_interval      => 60;
  }

  kbp_icinga::servicedependency { "percona_dependency_slaving_service":
    dependent_service_description => "Percona slaving",
    service_description           => "Percona service",
    execution_failure_criteria    => "u,w,c",
    notification_failure_criteria => "u,w,c";
  }

  fail("This class is untested and simply a copy from kbp_mysql.")
}

# Class: kbp_percona::server
#
# Parameters:
#  percona_name       The name of this Percona setup, used in combination with $environment to make sure the correct resources are imported
#  slow_query_time  Slow query log time in seconds; see percona documentation for long_query_time global variable. Set to false or 0 to disable.
#
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_percona::server($percona_name, $percona_version=false, $bind_address="0.0.0.0", $setup_backup=true, $datadir=false, $charset=false, $slow_query_time=10) {
  include kbp_trending::mysql
  include kbp_percona::monitoring::icinga::server
  class { "gen_percona::server":
    version => $percona_version,
    datadir => $datadir;
  }

  if $setup_backup and ! defined(Class['Kbp_backup::Disable']) {
    file { "/etc/backup/prepare.d/percona":
      ensure  => link,
      target  => "/usr/share/backup-scripts/prepare/mysql",
      require => Package["backup-scripts"];
    }

    file { "/etc/mysql/conf.d/expire_logs.cnf":
      content => "[mysqld]\nexpire_logs_days = 7\n";
    }
  } else {
    # Remove the backup script. Don't remove the expire_logs, since that might inadvertently fill up a disk
    # where binlogs are created but no longer removed. We just remove them earlier.
    file { "/etc/backup/prepare.d/percona":
      ensure => absent,
    }

    file { "/etc/mysql/conf.d/expire_logs.cnf":
      content => "[mysqld]\nexpire_logs_days = 1\n";
    }
  }

  file {
    "/etc/mysql/conf.d/bind-address.cnf":
      content => "[mysqld]\nbind-address = ${bind_address}\n",
      notify  => Service["percona"];
  }

  case $slow_query_time {
    false, 'false', 0, '0', /0\.0+$/: {
      file { '/etc/mysql/conf.d/slow-query-log.cnf':
        ensure => absent;
      }
    }
    default: {
      file { '/etc/mysql/conf.d/slow-query-log.cnf':
        content => template('kbp_mysql/slow-query-log.cnf'),
        require => Package[$gen_percona::server::perconaserver];
      }
    }
  }

  kbp_backup::exclude { "exclude_percona_data_dir":
    content => $datadir ? {
      false   => "/var/lib/mysql/*",
      default => $datadir,
    },
  }

  exec { 'remove_root_users':
    onlyif  => '/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e "select * from mysql.user where user=\'root\' and password=\'\'" | /bin/grep -q root',
    command => '/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e "delete from mysql.user where user=\'root\'; flush privileges"',
    require => Service["percona"];
  }

  Kbp_ferm::Rule <<| tag == "percona_${environment}_${percona_name}" |>>

  Gen_ferm::Rule <<| tag == "percona_monitoring" |>>

  # Stay compatible with MySQL
  Kbp_ferm::Rule <<| tag == "mysql_${environment}_${percona_name}" |>>

  Gen_ferm::Rule <<| tag == "mysql_monitoring" |>>
}

# Class: kbp_percona::server::ssl
#
# Parameters:
#  certname
#    The filename (without extention) of the keyfile and certificate (installed using kbp_ssl::keys{}).
#  intermediate
#    The name of the intermediate certificate in use.
#
# Actions:
#  Activate the ability to connect over SSL to the Percona server
#
# Depends:
#  kbp_percona::server
#  kbp_ssl::keys
#  gen_puppet
#
class kbp_percona::server::ssl ($certname=$fqdn, $intermediate){
  class { 'kbp_mysql::server::ssl':
    certname => $certname,
    intermediate => $intermediate,
  }
}

# Class: kbp_percona::monitoring::icinga::server
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
class kbp_percona::monitoring::icinga::server($otherhost=false) {
  kbp_icinga::service {
    "percona":
      service_description => "Percona service",
      check_command       => "check_mysql",
      nrpe                => true;
    "percona_connlimit":
      service_description => "Percona service connection limit",
      check_command       => "check_mysql_connlimit",
      nrpe                => true;
  }

  kbp_icinga::servicedependency { "percona_dependency_connlimit_service":
    dependent_service_description => "Percona service connection limit",
    service_description           => "Percona service",
    execution_failure_criteria    => "u,w,c",
    notification_failure_criteria => "u,w,c";
  }

  gen_percona::user { "monitoring":
    user => "nagios";
  }
}

class kbp_percona::client::java {
  include percona::java
  fail("This class is untested and simply a copy from kbp_mysql.")
}

# Define: kbp_percona::client
#
# Parameters:
#  percona_name
#    The name of the service that's using Percona
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
define kbp_percona::client ($percona_name, $address=$source_ipaddress, $environment=$environment) {
  include gen_base::percona_client

  kbp_ferm::rule { "Percona connections for ${name}":
    exported => true,
    saddr    => $address,
    proto    => "tcp",
    dport    => 3306,
    action   => "ACCEPT",
    ferm_tag => "percona_${environment}_${percona_name}";
  }
  fail("This define is untested and simply a copy from kbp_mysql.")
}

define kbp_percona::monitoring_dependency($this_fqdn=$fqdn) {
  if $this_fqdn != $fqdn {
    gen_icinga::servicedependency { "percona_dependency_${fqdn}":
      dependent_service_description => "Percona service",
      host_name                     => $this_fqdn,
      service_description           => "Percona service",
      tag                           => "percona_${environment}_${percona_name}";
    }
  }
  fail("This define is untested and simply a copy from kbp_mysql.")
}
