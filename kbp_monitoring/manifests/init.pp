# Author: Kumina bv <support@kumina.nl>

class kbp_monitoring::proxy($package="icinga", $proxytag="proxy_${environment}") {
  case $package {
    "icinga": {
      class { "kbp_icinga::proxy":
        proxytag => $proxytag;
      }
    }
  }
}

class kbp_monitoring::proxyclient($package="icinga", $proxy, $proxytag="proxy_${environment}", $saddr=false) {
  case $package {
    "icinga": {
      class { "kbp_icinga::proxyclient":
        proxy    => $proxy,
        proxytag => $proxytag,
        saddr    => $saddr;
      }
    }
  }

  kbp_ferm::rule {
    "NRPE monitoring":
      saddr    => $saddr,
      proto    => "tcp",
      dport    => 5666,
      action   => "ACCEPT";
    "MySQL monitoring":
      saddr    => $saddr,
      proto    => "tcp",
      dport    => 3306,
      action   => "ACCEPT";
    "Sphinxsearch monitoring":
      saddr    => $saddr,
      proto    => "tcp",
      dport    => 3312,
      action   => "ACCEPT";
    "Cassandra monitoring":
      saddr    => $saddr,
      proto    => "tcp",
      dport    => "(7000 8080 9160)",
      action   => "ACCEPT";
    "Glassfish monitoring":
      saddr    => $saddr,
      proto    => "tcp",
      dport    => 80,
      action   => "ACCEPT";
    "NFS monitoring":
      saddr    => $saddr,
      proto    => "(tcp udp)",
      dport    => "(111 2049)",
      action   => "ACCEPT";
    "DNS monitoring":
      saddr    => $saddr,
      proto    => "udp",
      dport    => 53,
      action   => "ACCEPT";
  }
}

class kbp_monitoring::client($package="icinga") {
  Kbp_ferm::Rule <<| tag == "general_monitoring" |>>
  Kbp_ferm::Rule <<| tag == "general_monitoring_${environment}" |>>

  case $package {
    "icinga": { include kbp_icinga::client }
    "nagios": { include kbp_nagios::client }
  }
}

# Class: kbp_monitoring::client::sslcert
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::client::sslcert {
  gen_sudo::rule { "check_sslcert sudo rules":
    entity            => "nagios",
    as_user           => "root",
    password_required => false,
    command           => "/usr/lib/nagios/plugins/check_sslcert";
  }
}

# Class: kbp_monitoring::server
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::server($package="icinga", $dbpassword=false, $dbhost=false) {
  case $package {
    "icinga": {
      class { "kbp_icinga::server":
        dbpassword => $dbpassword,
        dbhost     => $dbhost;
      }
    }
    "nagios": { include kbp_nagios::server }
  }

  kbp_ferm::rule {
    "NRPE monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => 5666,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "general_monitoring";
    "MySQL monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => 3306,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "mysql_monitoring";
    "Sphinxsearch monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => 3312,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "sphinxsearch_monitoring";
    "Cassandra monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => "(7000 8080 9160)",
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "cassandra_monitoring";
    "Glassfish monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => 80,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "glassfish_monitoring";
    "NFS monitoring":
      saddr    => $source_ipaddress,
      proto    => "(tcp udp)",
      dport    => "(111 2049)",
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "nfs_monitoring";
    "DNS monitoring":
      saddr    => $source_ipaddress,
      proto    => "udp",
      dport    => 53,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "dns_monitoring";
  }
}

# Class: kbp_monitoring::environment
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::environment($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::environment
    }
  }
}

# Class: kbp_monitoring::ferm_config
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::ferm_config($package="icinga", $filename) {
  case $package {
    "icinga": {
      class { "kbp_icinga::ferm_config":
        filename => $filename;
      }
    }
  }
}

# Class: kbp_monitoring::heartbeat
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::heartbeat($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::heartbeat
    }
  }
}

# Class: kbp_monitoring::pacemaker
#
# Parameters:
#  package
#    Which monitoring package to use
#
# Actions:
#  Set monitoring for pacemaker
#
# Depends:
#  gen_puppet
class kbp_monitoring::pacemaker ($package = "icinga"){
  case $package {
    "icinga": {
      gen_sudo::rule { "pacemaker sudo rules":
        entity => "nagios",
        as_user => "root",
        command => "/usr/sbin/crm_mon -s",
        password_required => false;
      }

      kbp_icinga::service { "pacemaker":
        service_description => "Pacemaker",
        check_command       => "check_pacemaker",
        nrpe                => true;
      }
    }
  }
}

# Class: kbp_monitoring::nfs::server
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::nfs::server($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::nfs::server
    }
  }
}

# Class: kbp_monitoring::nullmailer
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::nullmailer($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::nullmailer
    }
  }
}

# Class: kbp_monitoring::passenger::queue
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::passenger::queue($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::passenger::queue
    }
  }
}

# Class: kbp_monitoring::dhcp
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::dhcp($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::dhcp
    }
  }
}

# Class: kbp_monitoring::cassandra
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_monitoring::cassandra($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::cassandra
    }
  }
}

# Class: kbp_monitoring::asterisk
#
# Parameters:
#  package
#    Defines the monitoring package to use
#
# Actions:
#  Set up asterisk monitoring
#
# Depends:
#  kbp_icinga
#
class kbp_monitoring::asterisk($package="icinga") {
  case $package {
    "icinga": {
      include kbp_icinga::asterisk
    }
  }
}

# Define: kbp_monitoring::drbd
#
# Parameters:
#  name
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::drbd($package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::drbd { $name:; }
    }
  }
}

# Define: kbp_monitoring::nfs::client
#
# Parameters:
#  name
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::nfs::client($package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::nfs::client { $name:; }
    }
  }
}

# Define: kbp_monitoring::sslcert
#
# Parameters:
#  package
#    Undocumented
#  path
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::sslcert($path="/etc/ssl/certs/${name}.pem", $package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::sslcert { "${name}":
        path => $path;
      }
    }
  }
}

# Define: kbp_monitoring::haproxy
#
# Parameters:
#  ha
#    Undocumented
#  url
#    Undocumented
#  response
#    Undocumented
#  package
#    Undocumented
#  address
#    Undocumented
#  max_check_attempts
#    Number of retries before the monitoring considers the site down.
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::haproxy($address, $port=false, $ha=false, $host_name=false, $statuscode="200", $url=false,
    $response=false, $package="icinga", $max_check_attempts=false, $ssl=false, $preventproxyoverride=false) {
  case $package {
    "icinga": {
      kbp_icinga::haproxy { $name:
        address              => $address,
        ssl                  => $ssl,
        ha                   => $ha,
        statuscode           => $statuscode,
        url                  => $url,
        port                 => $port,
        host_name            => $host_name,
        max_check_attempts   => $max_check_attempts,
        response             => $response,
        preventproxyoverride => $preventproxyoverride;
      }
    }
  }
}

# Define: kbp_monitoring::java
#
# Parameters:
#  servicegroups
#    Undocumented
#  sms
#    Undocumented
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::java($package="icinga", $servicegroups=false, $sms=true) {
  case $package {
    "icinga": {
      kbp_icinga::java { "${name}":
        servicegroups => $servicegroups,
        sms           => $sms;
      }
    }
  }
}

# Define: kbp_monitoring::site
#
# Parameters:
#  address
#    Undocumented
#  conf_dir
#    Undocumented
#  false
#    Undocumented
#  parents
#    Undocumented
#  false
#    Undocumented
#  auth
#    Undocumented
#  package
#    Undocumented
#  max_check_attempts
#    For overriding the default max_check_attempts of the service.
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::site($package="icinga", $address=false, $address6=false, $conf_dir=$false, $parents=$fqdn, $auth=false,
    $max_check_attempts=false, $path=false, $response=false, $vhost=true, $statuscode=false, $ssl=false,
    $host_name=false, $service_description=false, $check_interval=false) {
  case $package {
    "icinga": {
      kbp_icinga::site { $name:
        address             => $address,
        address6            => $address6,
        conf_dir            => $conf_dir,
        parents             => $parents,
        max_check_attempts  => $max_check_attempts,
        auth                => $auth,
        path                => $path,
        response            => $response,
        vhost               => $vhost,
        statuscode          => $statuscode,
        ssl                 => $ssl,
        host_name           => $host_name,
        service_description => $service_description,
        check_interval      => $check_interval;
      }
    }
  }
}

# Define: kbp_monitoring::raidcontroller
#
# Parameters:
#  driver
#    Undocumented
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::raidcontroller($package="icinga", $driver) {
  case $package {
    "icinga": {
      kbp_icinga::raidcontroller { "${name}":
        driver => $driver;
      }
    }
  }
}

# Define: kbp_monitoring::http
#
# Parameters:
#  customfqdn
#    Undocumented
#  auth
#    Undocumented
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::http($package="icinga", $customfqdn=$fqdn, $auth=false, $proxy=false, $preventproxyoverride=false) {
  case $package {
    "icinga": {
      kbp_icinga::http { $name:
        customfqdn           => $customfqdn,
        auth                 => $auth,
        proxy                => $proxy,
        preventproxyoverride => $preventproxyoverride;
      }
    }
  }
}

# Define: kbp_monitoring::proc_status
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::proc_status($package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::proc_status { "${name}":; }
    }
  }
}

# Define: kbp_monitoring::sslsite
#
# Parameters:
#  package
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::sslsite($package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::sslsite { "${name}":; }
    }
  }
}

# Define: kbp_monitoring::glassfish
#
# Parameters:
#  package
#    Undocumented
#  statuspath
#    Undocumented
#  webport
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::glassfish($webport, $package="icinga", $statuspath=false) {
  case $package {
    "icinga": {
      kbp_icinga::glassfish { "${name}":
        webport    => $webport,
        statuspath => $statuspath ? {
          false   => undef,
          default => $statuspath,
        };
      }
    }
  }
}

# Define: kbp_monitoring::mbean_value
#
# Parameters:
#  package
#    Undocumented
#  statuspath
#    Undocumented
#  jmxport
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::mbean_value($jmxport, $objectname, $attributename, $expectedvalue, $attributekey=false, $customname=false, $package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::mbean_value { "${name}":
        jmxport       => $jmxport,
        objectname    => $objectname,
        attributename => $attributename,
        expectedvalue => $expectedvalue,
        attributekey  => $attributekey ? {
          false   => undef,
          default => $attributekey,
        },
        customname    => $customname;
      }
    }
  }
}

# Define: kbp_monitoring::dnszone
#
# Parameters:
#  sms
#    Undocumented
#  package
#    Undocumented
#  master
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::dnszone($master, $sms=true, $package="icinga") {
  case $package {
    "icinga": {
      kbp_icinga::dnszone { "${name}":
        master => $master,
        sms    => $sms;
      }
    }
  }
}

# Define: kbp_monitoring::ipsec
#
# Parameters:
#  name
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::ipsec($package="icinga", $monitoring_remote_ip) {
  case $package {
    "icinga": {
      kbp_icinga::ipsec{ $name:
        monitoring_remote_ip => $monitoring_remote_ip;
      }
    }
  }
}

# Define: kbp_monitoring::virtualhost
#
# Parameters:
#  conf_dir
#    Undocumented
#  parents
#    Undocumented
#  hostgroups
#    Undocumented
#  package
#    Undocumented
#  address
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_monitoring::virtualhost($address, $ensure=present, $conf_dir=false, $parents=false, $hostgroups=false, $package="icinga", $sms=true, $notification_period=false) {
  case $package {
    "icinga": {
      kbp_icinga::virtualhost { "${name}":
        address               => $address,
        ensure                => $ensure,
        conf_dir              => $conf_dir ? {
          false   => undef,
          default => $conf_dir,
        },
        parents               => $parents ? {
          false   => undef,
          default => $parents,
        },
        hostgroups            => $hostgroups ? {
          false   => undef,
          default => $hostgroups,
        },
        sms                   => $sms,
        notification_period   => $notification_period ? {
          false   => undef,
          default => $notification_period,
        };
      }
    }
  }
}
