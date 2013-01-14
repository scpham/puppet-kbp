# Author: Kumina bv <support@kumina.nl>

# Class: kbp_powerdns::master
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_powerdns::master {
  include powerdns::master

  Kbp_ferm::Rule <<| tag == "bind_${environment}" |>>

  # Poweradmin MySQL access
  Kbp_ferm::Rule <<| tag == "poweradmin_${environment}" |>>

  Gen_ferm::Rule <<| tag == "dns_monitoring" |>>
}

# Class: kbp_powerdns::authoritative::master
#
# Actions: Install the PowerDNS authoritative server and setup MySQL in mastermode. It also adds users and permissions to the database.
#
# Parameters:
#  db_password      The password for the pdns user (which has read-only) access
#  ssl_certlocation The location of the SSL certificate/key
#  ssl_intermediate The name of the intermediate certificate
#  admin_password   The password for the read/write pdns_admin user
#  mysql_tag        The tag for this MySQL cluster
#  localaddress     The address where PowerDNS should bind
#
# Depends:
#  kbp_powerdns::authoritative
#
class kbp_powerdns::authoritative::master ($db_password, $certlocation, $intermediate, $admin_password, $mysql_tag='powerdns', $localaddress=$::external_ipaddress) {
  class {
    'kbp_powerdns::authoritative':
      localaddress => $localaddress;
    'kbp_mysql::master':
      mysql_tag    => $mysql_tag;
    'kbp_mysql::server::ssl':
      certlocation => $certlocation,
      intermediate => $intermediate;
  }

  mysql::server::grant {
    'pdns_admin on pdns':
      permissions => 'select, insert, update, delete',
      password    => $admin_password;
    'pdns on pdns':
      permissions => 'select',
      password    => $db_password;
  }

  Mysql::Server::Grant <<| tag == "powerdns_admin_${environment}" |>>

  file {
    '/etc/powerdns/admin':
      ensure  => directory,
      require => Package['pdns-server'];
    '/etc/powerdns/admin/pdns.conf':
      content => template('kbp_powerdns/admin_pdns.conf'),
      mode    => 440;
  }

  # This export is imported by ALL kbp_powerdns::authoritative imports to configure its database settings.
  @@gen_powerdns::backend::mysql { "pdns_${environment}":
    db_password => $db_password;
  }

  @@host { $fqdn:
    ip  => $external_ipaddress,
    tag => "powerdns_${environment}";
  }

  Kbp_ferm::Rule <<| tag == "pdns_admin_${environment}" |>>
}

# Class: kbp_powerdns::authoritative::slave
#
# Actions: Install the PowerDNS authoritative server and setup MySQL in slavemode.
#
# Parameters:
#  repl_password    The password for the pdns_repl user
#  ssl_intermediate The name of the intermediate certificate
#  mysql_tag        The tag for this MySQL cluster
#  localaddress     The address where PowerDNS should bind
#
# Depends:
#  kbp_powerdns::authoritative
#
class kbp_powerdns::authoritative::slave ($repl_password, $intermediate, $mysql_tag='powerdns', $localaddress=$::external_ipaddress){
  include "kbp_ssl::intermediate::${intermediate}"
  class {
    'kbp_powerdns::authoritative':
      localaddress     => $localaddress;
    'kbp_mysql::slave':
      mysql_tag        => $mysql_tag,
      repl_user        => 'pdns_repl',
      repl_password    => $repl_password,
      repl_require_ssl => true,
      bind_address     => '127.0.0.1',
      setup_backup     => false;
  }

  Host <<| tag == "powerdns_${environment}" |>>
}

# Class: kbp_powerdns::authoritative
#
# Actions: Install the PowerDNS authoritative server and setup monitoring/trending
#
# Parameters:
#  localaddress     The address where PowerDNS should bind (multiple addresses should be space-separated)
#
# Depends:
#  gen_powerdns
#
class kbp_powerdns::authoritative ($localaddress) {
  include kbp_munin::client::powerdns
  class { 'gen_powerdns':
    localaddress => $localaddress;
  }

  Gen_powerdns::Backend::Mysql <<| title == "pdns_${environment}" |>>

  kbp_ferm::rule { 'PowerDNS':
    proto  => '(tcp udp)',
    daddr  => "(${localaddress})",
    dport  => 53,
    action => ACCEPT;
  }

  kbp_icinga::proc_status { 'pdns':; }
}

# Class: kbp_powerdns::admin
#
# Actions: Setup a Django site for the pdns-manager application
#
# Parameters:
#  dbserver     The server on which the pdns database resides
#  sitename     The url for this website (like pdnsadmin.yousite.com)
#  intermediate The intermediate certificate
#  cert         The certificate used for the site
#  wildcard     The wildcard certificate for this site
#
class kbp_powerdns::admin ($dbserver, $adminpassword, $sitename, $intermediate=false, $cert=false, $wildcard=false) {
  include gen_base::python_mysqldb
  include gen_base::python-dnspython

  kbp_ferm::rule { 'pdns_admin access':
    saddr    => $external_ipaddress,
    dport    => 3306,
    proto    => tcp,
    exported => true,
    action   => 'ACCEPT',
    ferm_tag => "pdns_admin_${environment}";
  }

  @@mysql::server::grant { 'pdns_admin on pdns':
    permissions => 'select, insert, update, delete',
    password    => $admin_password,
    hostname    => $fqdn,
    tag         => "powerdns_admin_${environment}"
  }

  kbp_django::site { $sitename:
    cert         => $cert,
    intermediate => $intermediate,
    wildcard     => $wildcard;
  }

  if $cert or $intermediate or $wildcard {
    $ssl = true
  }

  kbp_apache::vhost_addition { "${sitename}/static":
    ports   => $ssl ? {
      true    => 443,
      default => 80,
    },
    content => "Alias /static /usr/share/pyshared/django/contrib/admin/static/\n",
  }
}
