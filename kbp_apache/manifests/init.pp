# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apache
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache {
  include gen_apache
  include kbp_munin::client::apache

  # Needed for /server-status (munin) when using NameVirtualHosts
  kbp_apache::site { 'localhost':
    address      => '127.0.0.255',
    address6     => '::1',
    documentroot => '/var/www',
    monitor      => false;
  }

  file {
    "/etc/apache2/mods-available/deflate.conf":
      content => template("kbp_apache/mods-available/deflate.conf"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
    "/etc/apache2/conf.d/security":
      content => template("kbp_apache/conf.d/security"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
    # Also needed for the /server-status page
    '/etc/apache2/conf.d/server-status':
      content => template('kbp_apache/conf.d/server-status'),
      require => Package['apache2'],
      notify  => Exec['reload-apache2'];
  }

  # There are classes that override /srv/www (think the NFS class), this makes sure
  # that will work.
  if ! defined(File["/srv/www"]) {
    file { "/srv/www":
      ensure => directory;
    }
  }

  gen_logrotate::rotate { "apache2":
    logs       => "/var/log/apache2/*.log",
    options    => ["weekly", "rotate 52", "missingok", "notifempty", "create 640 root adm", "compress", "delaycompress", "sharedscripts", "dateext"],
    postrotate => "/etc/init.d/apache2 reload > /dev/null",
    require    => Package["apache2"];
  }

  kbp_apache::module { ["deflate","rewrite"]:; }

  kbp_icinga::http { "http_${fqdn}":; }
}

# Class: kbp_apache::global_umask_007
#
# Actions:
#  Set the umask of the Apache process to 007, for broken scripts that otherwise create files
#  world-readable/writable.
#
# Depends:
#  kbp_apache
#
class kbp_apache::global_umask_007 {
  line { "Set Apache's umask":
    file    => "/etc/apache2/envvars",
    content => "umask 007",
    require => Package["apache2"];
  }
}

# Class: kbp_apache::passenger
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache::passenger {
  include kbp_apache
  include gen_base::libapache2-mod-passenger
  include kbp_apache::module::passenger
  include kbp_icinga::passenger::queue
}

class kbp_apache::php {
  include kbp_apache::php_common
  include gen_base::libapache2_mod_php5
}

# Class: kbp_apache::phpcommon
#
# Actions:
#  Set up common resources for all php methods, currently only used for dashboard
#
class kbp_apache::php_common {}

# Class: kbp_apache::mem_cache
#
# Actions:
#  Enables the mem_cache module, but disables the default config, since we don't want it for all sites.
#
# Depends:
#  kbp_apache::module
#
class kbp_apache::mem_cache {
  kbp_apache::module { "mem_cache":; }

  # We do not like the default config for all sites
  file { "/etc/apache2/mods-enabled/mem_cache.conf":
    ensure  => absent,
    require => Kbp_apache::Module["mem_cache"],
    notify  => Exec["force-reload-apache2"];
  }
}

# Class: kbp_apache::ssl
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache::ssl {
  kbp_apache::module { "ssl":; }
}

# Class: kbp_apache::module::passenger
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_apache::module::passenger {
  kbp_apache::module { "passenger":
    require => Package["libapache2-mod-passenger"];
  }
}

class kbp_apache::module::expires {
  kbp_apache::module { "expires":; }
}

class kbp_apache::module::dav {
  kbp_apache::module { "dav":; }
}

class kbp_apache::module::dav_fs {
  kbp_apache::module { "dav_fs":; }
}

class kbp_apache::module::auth_mysql {
  include gen_base::libapache2-mod-auth-mysql

  kbp_apache::module { "auth_mysql":
    require => Package["libapache2-mod-auth-mysql"],
  }
}

class kbp_apache::module::auth_digest {
  kbp_apache::module { "auth_digest":; }
}

class kbp_apache::module::proxy_http {
  kbp_apache::module { "proxy_http":
    notify => Exec["force-reload-apache2"];
  }
}

class kbp_apache::module::jk {
  include gen_apache::jk

  file { "/var/cache/apache2/jk":
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Package["apache2"],
  }
}

class kbp_apache::module::headers {
  kbp_apache::module { "headers":; }
}

# Class: kbp_apache::cgid
#
# Action:
#  Setup the mod-cgid module in Apache with default settings.
#
# Depends:
#  kbp_apache::module
#
class kbp_apache::module::cgid {
  kbp_apache::module { "cgid":; }
}

class kbp_apache::glassfish_domain_base {
  include kbp_apache::module::jk

  concat { "/etc/apache2/workers.properties":
    require => Package["apache2"];
  }

  concat::add_content {
    "0 worker base":
      content   => "worker.list=",
      linebreak => false,
      target    => "/etc/apache2/workers.properties";
    "2 worker base":
      content => "",
      target  => "/etc/apache2/workers.properties";
  }

  file { "/etc/apache2/conf.d/jk":
    content => template("kbp_apache/conf.d/jk");
  }
}

define kbp_apache::php_cgi($ensure="present", $documentroot, $custom_php_ini=false, $ports=false) {
  if $ensure == "present" {
    include kbp_apache::php_common
    include gen_php5::cgi
    include kbp_php5::apc
    include gen_base::apache2_mpm_worker

    kbp_apache::cgi { $name:
      documentroot   => $documentroot,
      custom_php_ini => $custom_php_ini,
      ports          => $ports;
    }

    Package <| title == "libapache2-mod-php5" |> {
      ensure => purged,
      notify => Exec["force-reload-apache2"],
    }

    if !defined(Kbp_apache::Php_cgi['localhost_80']) {
      kbp_apache::php_cgi { 'localhost_80':
        documentroot   => '/var/www';
      }
    }
  }
}

# Define: kbp_apache::site
#
# Parameters:
#  priority
#    Undocumented
#  ensure
#    Undocumented
#  max_check_attempts
#    For overriding the default max_check_attempts of the service
#  log_vhost
#    If set to true, it logs the serveralias from the request in the access log
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_apache::site($ensure="present", $serveralias=false, $documentroot = "/srv/www/${name}", $address='*', $address6='::', $make_default=false, $ssl=false, $non_ssl=true, $key=false, $cert=false, $intermediate=false,
    $wildcard=false, $log_vhost=false, $access_logformat="combined", $redirect_non_ssl=true, $auth=false, $max_check_attempts=false, $monitor_path=false, $monitor_response=false, $monitor_probe=false, $monitor_creds=false,
    $monitor_check_interval=false,$monitor=true, $smokeping=true, $php=false, $custom_php_ini=false, $phpmyadmin=false, $ha=false, $monitor_ip=false, $monitor_proxy=false, $failover=false, $port=false, $monitor_statuscode=false,
    $webdav=false) {
  include kbp_apache

  if regsubst($name, '^(.*)_.*$', '\1') != $name {
    fail("Only pass the site name to kbp_apache::site, not ${name}")
  }

  if $failover and $address == '*' and $address6 == '*' {
    fail("Site ${name} has failover set to true but no address or address6 is supplied.")
  }

  if $key or $cert or $intermediate or $wildcard or $ssl {
    include kbp_apache::ssl
    if $intermediate {
      include "kbp_ssl::intermediate::${intermediate}"
    }

    $real_ssl = true

    if $make_default and ! $non_ssl {
      Kbp_icinga::Http <| title == "http_${fqdn}" |> {
        ssl => true,
      }
    }
  } else {
    $real_ssl = false
  }
  $real_port        = $port ? {
    false   => $real_ssl ? {
      false => 80,
      true  => 443,
    },
    default => $port,
  }
  $real_intermediate = $intermediate ? {
    false         => false,
    'positivessl' => 'PositiveSSLCA.pem',
    'rapidssl'    => 'RapidSSL_CA_bundle.pem',
    'terena'      => 'TerenaCA.pem',
    'thawte'      => 'Thawte_SSL_CA.pem',
    'verisign'    => 'verisign_bundle.pem',
  }
  $full_name   = regsubst($name, '^([^_]*)$', "\1_${real_port}")
  $dontmonitor = ["default","default-ssl","localhost"]

  gen_apache::site { $full_name:
    ensure           => $ensure,
    serveralias      => $serveralias,
    documentroot     => $documentroot,
    address          => $address,
    address6         => $address6,
    log_vhost        => $log_vhost,
    access_logformat => $access_logformat,
    make_default     => $make_default,
    ssl              => $ssl,
    key              => $key,
    cert             => $cert,
    intermediate     => $real_intermediate,
    wildcard         => $wildcard;
  }

  if $ensure == "present" and $monitor and ! ($name in $dontmonitor) {
    if $real_ssl {
      $monitor_name = "${name}_SSL"
    } else {
      $monitor_name = $name
    }

    $real_monitor_ip = $monitor_ip ? {
      false   => $address,
      default => $monitor_ip,
    }

    kbp_icinga::site { "${name}_${real_monitor_ip}":
      service_description => $service_description,
      max_check_attempts  => $max_check_attempts,
      auth                => $auth,
      path                => $monitor_path,
      response            => $monitor_response,
      credentials         => $monitor_creds,
      check_interval      => $monitor_check_interval,
      ha                  => $failover ? {
        true  => false,
        false => $ha,
      },
      ssl                 => $real_ssl,
      proxy               => $monitor_proxy,
      statuscode          => $monitor_statuscode,
      nrpe                => $failover;
    }

    kbp_icinga::servicedependency { "apache_dependency_${monitor_name}_http":
      dependent_service_description => $real_ssl ? {
        false => "Vhost ${name}",
        true  => "Vhost ${name} SSL",
      },
      service_description           => 'HTTP',
      execution_failure_criteria    => 'w,u,c',
      notification_failure_criteria => 'w,u,c';
    }

    if $failover {
      kbp_icinga::site { "${name}_${real_monitor_ip}__fo":
        service_description => $service_description,
        max_check_attempts  => $max_check_attempts,
        auth                => $auth,
        path                => $monitor_path,
        response            => $monitor_response,
        credentials         => $monitor_creds,
        check_interval      => $monitor_check_interval,
        ha                  => $ha,
        ssl                 => $real_ssl,
        proxy               => $monitor_proxy,
        vhost               => false,
        statuscode          => $monitor_statuscode;
      }
    }

    if $smokeping {
      kbp_smokeping::target { $name:
        probe => $monitor_probe ? {
          false   => $auth ? {
            false => undef,
            true  => "FPing",
          },
          default => $monitor_probe,
        },
        path  => $monitor_path;
      }
    }
  }

  if $real_ssl and $non_ssl {
    if $redirect_non_ssl {
      kbp_apache::forward_vhost { $name:
        ensure      => $ensure,
        address     => $address,
        address6    => $address6,
        forward     => "https://${name}",
        serveralias => $serveralias,
        monitor_ip  => $real_monitor_ip;
      }
    } else {
      gen_apache::site { "${name}_80":
        ensure           => $ensure,
        serveralias      => $serveralias,
        documentroot     => $documentroot,
        address          => $address,
        address6         => $address6,
        log_vhost        => $log_vhost,
        access_logformat => $access_logformat,
        make_default     => $make_default;
      }

      kbp_icinga::site { "${name}_${real_monitor_ip}_80":
        service_description => $service_description,
        max_check_attempts  => $max_check_attempts,
        auth                => $auth,
        path                => $monitor_path,
        response            => $monitor_response,
        credentials         => $monitor_creds,
        check_interval      => $monitor_check_interval,
        ha                  => $failover ? {
          true  => false,
          false => $ha,
        },
        statuscode          => $monitor_statuscode,
        nrpe                => $failover;
      }

      kbp_icinga::servicedependency { "apache_dependency_${name}_http":
        dependent_service_description => "Vhost ${name}",
        service_description           => 'HTTP',
        execution_failure_criteria    => 'w,u,c',
        notification_failure_criteria => 'w,u,c';
      }

      if $failover {
        kbp_icinga::site { "${name}_${real_monitor_ip}_80_fo":
          service_description => $service_description,
          max_check_attempts  => $max_check_attempts,
          auth                => $auth,
          path                => $monitor_path,
          response            => $monitor_response,
          credentials         => $monitor_creds,
          check_interval      => $monitor_check_interval,
          ha                  => $ha,
          vhost               => false,
          statuscode          => $monitor_statuscode;
        }
      }
    }
  }

  if ! defined(Gen_ferm::Rule["HTTP(S) connections on ${real_port}"]) {
    gen_ferm::rule { "HTTP(S) connections on ${real_port}":
      proto  => "tcp",
      dport  => $real_port,
      action => "ACCEPT";
    }
  }

  if $php {
    case $php {
      # Mod_php, I choose you!
      'mod_php': {
        include kbp_apache::php
      }
      # Default to CGI
      default:   {
        if $real_ssl and $non_ssl and ! $redirect_non_ssl {
          $ports = [80, 443]
        } else {
          $ports = false
        }

        kbp_apache::php_cgi { $full_name:
          documentroot   => $documentroot,
          custom_php_ini => $custom_php_ini,
          ports          => $ports;
        }
      }
    }
  }

  if $phpmyadmin {
    case $php {
      'mod_php': { include kbp_phpmyadmin      }
      default:   { include kbp_phpmyadmin::cgi }
    }

    file { "/etc/apache2/vhost-additions/${full_name}/phpmyadmin":
      ensure  => link,
      target  => "/etc/phpmyadmin/apache.conf",
      notify  => Exec["reload-apache2"],
      require => Package["phpmyadmin"],
    }
  }

  if $webdav {
    include kbp_apache::module::dav
    include kbp_apache::module::dav_fs

    kbp_apache::vhost_addition { "${name}/webdav":
      ports   => '443',
      content => "<Location />\nDav On\nForceType text/plain\n</Location>",
    }
  }
}

define kbp_apache::module ($ensure = "enable") {
  gen_apache::module { $name:
    ensure => $ensure;
  }
}

define kbp_apache::forward_vhost ($forward, $address='*', $address6='::', $ensure="present", $serveralias=false, $statuscode=301, $port=80, $monitor_ip=$address, $preserve_path=true) {
  $real_monitor_ip = $monitor_ip ? {
    '*'     => '',
    default => $monitor_ip,
  }

  gen_apache::forward_vhost { $name:
    forward       => $forward,
    address       => $address,
    address6      => $address6,
    ensure        => $ensure,
    preserve_path => $preserve_path,
    serveralias   => $serveralias,
    statuscode    => $statuscode,
    port          => $port;
  }

  kbp_icinga::site { "${name}_${real_monitor_ip}_${port}_forward":
    service_description => "Vhost ${name} forward",
    statuscode          => $statuscode,
    response            => $forward;
  }

  if ! defined(Gen_ferm::Rule["HTTP(S) connections on ${port}"]) {
    gen_ferm::rule { "HTTP(S) connections on ${port}":
      proto  => "tcp",
      dport  => $port,
      action => "ACCEPT";
    }
  }
}

define kbp_apache::vhost_addition($ensure="present", $content=false, $ports = 80) {
  if regsubst($name, '^(.*)_.*/.*$', '\1') != $name {
    fail("Vhost addition ${name}: Passing the port in the name of a kbp_apache::vhost_addition is no longer allowed, use the ports param (defaults to 80).")
  }

  $names = split(inline_template("<% name_array = name.split('/') %><%= [ports].flatten.map { |x| name_array[0]+'_'+x.to_s+'/'+name_array[1] }.join(' ') %>"), ' ')

  gen_apache::vhost_addition { $names:
    ensure  => $ensure,
    content => $content ? {
      false   => undef,
      default => $content,
    };
  }
}

define kbp_apache::glassfish_domain($site, $port, $connector_port, $connector_loglevel="info") {
  include kbp_apache::glassfish_domain_base

  kbp_apache::vhost_addition { "${site}/glassfish-jk":
    ports   => $port,
    content => "JkLogLevel ${connector_loglevel}\nJkMount /* ${name}\n";
  }

  concat::add_content {
    "1 worker domain ${name}":
      content   => "${name},",
      linebreak => false,
      target    => "/etc/apache2/workers.properties";
    "3 worker domain ${name} settings":
      content => template("kbp_apache/glassfish/workers.properties_settings"),
      target  => "/etc/apache2/workers.properties";
  }
}

define kbp_apache::cgi($documentroot=false, $custom_php_ini=false, $set_scriptalias=true, $ports=false) {
  include gen_base::libapache2-mod-fcgid

  $real_name = regsubst($name, '^(.*)_.*$', '\1')
  $port      = regsubst($name, '^.*_(.*)$', '\1')

  kbp_apache::vhost_addition { "${real_name}/enable-cgi":
    ports   => $ports ? {
      false   => $port,
      default => $ports,
    },
    content => template("kbp_apache/vhost-additions/enable_cgi");
  }
}
