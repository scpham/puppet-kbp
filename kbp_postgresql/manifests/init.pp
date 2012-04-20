# Author: Kumina bv <support@kumina.nl>

# Class: kbp_postgresql::server
#
# Actions:
#  Setup a PostgreSQL server.
#
# Parameters:
#  postgresql_name
#    The name of this PostgreSQL setup, used in combination with $environment to make sure the correct resources are imported
#  bind_address
#    The address to listen on.
#  setup_backup
#    If backup needs to be configured for this machine or not.
#  datadir
#    The directory to use for data storage.
#  version
#    The PostgreSQL version to install.
#
# Depends:
#  gen_postgresql
#  gen_apt
#  gen_puppet
#
class kbp_postgresql::server($postgresql_name, $bind_address="0.0.0.0", $setup_backup=true, $datadir=false, $version='8.4') {
  include kbp_trending::postgresql
  include kbp_postgresql::monitoring::icinga::server
  class { "gen_postgresql::server":
    datadir => $datadir,
    version => $version;
  }

  # If we're on Squeeze and we want a version higher than 8.4, we need to pin stuff to backports
  if $lsbmajdistrelease < 7 and versioncmp($version,'8.4') > 0 {
    gen_apt::preference { ["postgresql-${version}","libpq5","postgresql-client-9.1","postgresql-common","postgresql-client-common"]:; }

    package {
      "postgresql-client-${version}":
        require => Package["postgresql-common","postgresql-client-common"],
        notify  => Package["postgresql-server"];
      "postgresql-common":
        require => Package["postgresql-client-common"],
        notify  => Package["postgresql-server"];
      "postgresql-client-common":;
    }
  }

  if $setup_backup {
    file { "/etc/backup/prepare.d/postgresql":
      ensure  => link,
      target  => "/usr/share/backup-scripts/prepare/postgresql",
      require => Package["backup-scripts"];
    }
  }

  kbp_backup::exclude { "exclude_var_lib_postgresql":
    content => "/var/lib/postgresql/*";
  }

  Kbp_ferm::Rule <<| tag == "postgresql_${environment}_${postgresql_name}" |>>

  Gen_ferm::Rule <<| tag == "postgresql_monitoring" |>>
}

# Class: kbp_postgresql::monitoring::icinga::server
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
class kbp_postgresql::monitoring::icinga::server($otherhost=false) {
  kbp_icinga::service {
    "postgresql":
      service_description => "PostgreSQL service",
      check_command       => "check_pgsql",
      nrpe                => true;
  }

  kbp_sudo::rule { "Allow user nagios to check postgresql as postgres user":
    command           => "/usr/lib/nagios/plugins/check_pgsql",
    as_user           => "postgres",
    entity            => "nagios",
    password_required => false;
  }
}

# Define: kbp_postgresql::client
#
# Parameters:
#  postgresql_name
#    The name of the service that's using PostgreSQL
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
define kbp_postgresql::client ($postgresql_name, $address=$fqdn, $environment=$environment) {
  include gen_postgresql::client

  kbp_ferm::rule { "PostgreSQL connections for ${name}":
    exported => true,
    saddr    => $address,
    proto    => "tcp",
    dport    => 5432,
    action   => "ACCEPT",
    ferm_tag => "postgresql_${environment}_${postgresql_name}";
  }
}
