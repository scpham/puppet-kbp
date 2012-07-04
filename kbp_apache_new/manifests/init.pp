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
class kbp_apache_new {
  include gen_apache
  include kbp_munin::client::apache

  # Needed for /server-status (munin) when using NameVirtualHosts
  kbp_apache_new::site { 'localhost':
    address             => '127.0.0.1',
    address6            => '::1',
    documentroot        => '/srv/www',
    create_documentroot => false,
    monitor             => false;
  }

  file {
    "/etc/apache2/mods-available/deflate.conf":
      content => template("kbp_apache_new/mods-available/deflate.conf"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
    "/etc/apache2/conf.d/security":
      content => template("kbp_apache_new/conf.d/security"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
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

  kbp_apache_new::module { ["deflate","rewrite"]:; }

  kbp_icinga::http { "http_${fqdn}":; }

  kbp_dashboard::service::wrapper { 'apache':
    fullname => 'Apache';
  }
}

# Class: kbp_apache_new::global_umask_007
#
# Actions:
#  Set the umask of the Apache process to 007, for broken scripts that otherwise create files
#  world-readable/writable.
#
# Depends:
#  kbp_apache_new
#
class kbp_apache_new::global_umask_007 {
  line { "Set Apache's umask":
    file    => "/etc/apache2/envvars",
    content => "umask 007",
    require => Package["apache2"]
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
class kbp_apache_new::passenger {
  include kbp_apache_new
  include gen_base::libapache2-mod-passenger
  include kbp_apache_new::module::passenger
  include kbp_icinga::passenger::queue
}

class kbp_apache_new::php {
  include kbp_apache_new::php_common
  include gen_base::libapache2_mod_php5
}

# Class: kbp_apache_new::mem_cache
#
# Actions:
#  Enables the mem_cache module, but disables the default config, since we don't want it for all sites.
#
# Depends:
#  kbp_apache_new::module
#
class kbp_apache_new::mem_cache {
  kbp_apache_new::module { "mem_cache":; }

  # We do not like the default config for all sites
  file { "/etc/apache2/mods-enabled/mem_cache.conf":
    ensure  => absent,
    require => Kbp_apache_new::Module["mem_cache"],
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
class kbp_apache_new::ssl {
  kbp_apache_new::module { "ssl":; }
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
class kbp_apache_new::module::passenger {
  kbp_apache_new::module { "passenger":
    require => Package["libapache2-mod-passenger"];
  }
}

class kbp_apache_new::module::expires {
  kbp_apache_new::module { "expires":; }
}

class kbp_apache_new::module::dav {
  kbp_apache_new::module { "dav":; }
}

class kbp_apache_new::module::dav_fs {
  kbp_apache_new::module { "dav_fs":; }
}

class kbp_apache_new::module::auth_mysql {
  include gen_base::libapache2-mod-auth-mysql

  kbp_apache_new::module { "auth_mysql":
    require => Package["libapache2-mod-auth-mysql"],
  }
}

class kbp_apache_new::module::proxy_http {
  kbp_apache_new::module { "proxy_http":
    notify => Exec["force-reload-apache2"];
  }
}

class kbp_apache_new::module::jk {
  include gen_apache::jk

  file { "/var/cache/apache2/jk":
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Package["apache2"],
  }
}

class kbp_apache_new::module::headers {
  kbp_apache_new::module { "headers":; }
}

class kbp_apache_new::intermediate::rapidssl {
  kbp_ssl::public_key { "RapidSSL_CA_bundle":
    content => template("kbp_apache_new/ssl/RapidSSL_CA_bundle.pem"),
    notify  => Exec["reload-apache2"];
  }
}

class kbp_apache_new::intermediate::positivessl {
  kbp_ssl::public_key { "PositiveSSLCA":
    content => template("kbp_apache_new/ssl/PositiveSSLCA.pem"),
    notify  => Exec["reload-apache2"];
  }
}

class kbp_apache_new::intermediate::thawte {
  kbp_ssl::public_key { "Thawte_SSL_CA":
    content => template("kbp_apache_new/ssl/Thawte_SSL_CA.pem"),
    notify  => Exec["reload-apache2"];
  }
}

class kbp_apache_new::intermediate::verisign {
  kbp_ssl::public_key { "Verisign_SSL_CA":
    content => template("kbp_apache_new/ssl/verisign_bundle.pem"),
    notify  => Exec["reload-apache2"];
  }
}

class kbp_apache_new::glassfish_domain_base {
  include kbp_apache_new::module::jk

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
    content => template("kbp_apache_new/conf.d/jk");
  }
}

class kbp_apache_new::php_common {
  kbp_dashboard::service_plugin::wrapper { 'php':
    fullname => 'PHP',
    service  => 'apache';
  }
}

define kbp_apache_new::php_cgi($ensure="present", $documentroot, $custom_php_ini=false) {
  if $ensure == "present" {
    include kbp_apache_new::php_common
    include gen_php5::cgi
    include gen_php5::apc
    include gen_base::apache2_mpm_worker

    kbp_apache_new::cgi { $name:
      documentroot   => $documentroot,
      custom_php_ini => $custom_php_ini;
    }

    Package <| title == "libapache2-mod-php5" |> {
      ensure => purged,
      notify => Exec["force-reload-apache2"],
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
define kbp_apache_new::site($ensure="present", $serveralias=false, $documentroot=false, $create_documentroot=true, $address='*', $address6='::',
    $port=false, $make_default=false, $ssl=false, $non_ssl=true, $key=false, $cert=false, $intermediate=false, $wildcard=false, $log_vhost=false, $access_logformat="combined",
    $redirect_non_ssl=true, $auth=false, $max_check_attempts=false, $monitor_path=false, $monitor_response=false, $monitor_probe=false, $monitor_creds=false,
    $monitor_check_interval=false,$monitor=true, $smokeping=true, $php=false, $custom_php_ini=false, $glassfish_domain=false, $glassfish_connector_port=false,
    $glassfish_connector_loglevel="info", $django_root_path=false,$django_root_django=false, $django_static_path=false, $django_static_django=false,
    $django_settings=false, $phpmyadmin=false, $ha=false, $monitor_ip=false) {
  include kbp_apache_new

  $temp_name   = $port ? {
    false   => $name,
    default => "${name}_${port}",
  }
  if $key or $cert or $intermediate or $wildcard or $ssl {
    include kbp_apache_new::ssl

    $real_ssl = true
    $full_name = regsubst($temp_name,'^([^_]*)$','\1_443')

    if $make_default and ! $non_ssl {
      Kbp_icinga::Http <| title == "http_${fqdn}" |> {
        ssl => true,
      }
    }
  } else {
    $real_ssl = false
    $full_name = regsubst($temp_name,'^([^_]*)$','\1_80')
  }
  $real_name   = regsubst($full_name,'^(.*)_(.*)$','\1')
  $real_port   = regsubst($full_name,'^(.*)_(.*)$','\2')
  $dontmonitor = ["default","default-ssl","localhost"]
  $real_documentroot = $documentroot ? {
    false   => "/srv/www/${real_name}",
    default => $documentroot,
  }

  gen_apache::site { $full_name:
    ensure              => $ensure,
    serveralias         => $serveralias,
    create_documentroot => $create_documentroot,
    documentroot        => $real_documentroot,
    address             => $address,
    address6            => $address6,
    port                => $port,
    log_vhost           => $log_vhost,
    access_logformat    => $access_logformat,
    make_default        => $make_default,
    ssl                 => $ssl,
    key                 => $key,
    cert                => $cert,
    intermediate        => $intermediate,
    wildcard            => $wildcard;
  }

  if $ensure == "present" and $monitor and ! ($name in $dontmonitor) {
    if $real_ssl {
      $monitor_name = "${real_name}_SSL"
    } else {
      $monitor_name = $real_name
    }

    $real_monitor_ip = $monitor_ip ? {
      false   => $address,
      default => $monitor_ip,
    }

    kbp_icinga::site { $monitor_name:
      service_description => $service_description,
      address             => $real_monitor_ip,
      address6            => $address6,
      host_name           => $real_name,
      max_check_attempts  => $max_check_attempts,
      auth                => $auth,
      path                => $monitor_path,
      response            => $monitor_response,
      credentials         => $monitor_creds,
      check_interval      => $monitor_check_interval,
      ha                  => $ha,
      ssl                 => $real_ssl;
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
      kbp_apache_new::forward_vhost { $real_name:
        ensure      => $ensure,
        address     => $address,
        address6    => $address6,
        forward     => "https://${real_name}",
        serveralias => $serveralias,
        monitor_ip  => $real_monitor_ip;
      }
    } else {
      gen_apache::site { "${real_name}_80":
        ensure              => $ensure,
        serveralias         => $serveralias,
        create_documentroot => $create_documentroot,
        documentroot        => $real_documentroot,
        address             => $address,
        address6            => $address6,
        port                => $port,
        log_vhost           => $log_vhost,
        access_logformat    => $access_logformat,
        make_default        => $make_default;
      }

      kbp_icinga::site { $real_name:
        service_description => $service_description,
        address             => $real_monitor_ip,
        address6            => $address6,
        host_name           => $real_name,
        max_check_attempts  => $max_check_attempts,
        auth                => $auth,
        path                => $monitor_path,
        response            => $monitor_response,
        credentials         => $monitor_creds,
        check_interval      => $monitor_check_interval,
        ha                  => $ha,
        ssl                 => false;
      }
    }

    if ! $wildcard {
      if $cert {
        kbp_icinga::sslcert { $cert:; }
      } else {
        kbp_icinga::sslcert { $real_name:; }
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

  if $glassfish_domain {
    if ! $glassfish_connector_port {
      fail { "glassfish_connector_port is undefined for ${site}":; }
    }

    kbp_apache_new::glassfish_domain { $glassfish_domain:
      site               => $real_name,
      site_port          => $real_port,
      connector_loglevel => $glassfish_connector_loglevel,
      connector_port     => $glassfish_connector_port;
    }
  }

  if $django_settings {
    include kbp_django

    $real_django_root_path = $django_root_path ? {
      false   => '/',
      default => $django_root_path,
    }
    $real_django_root_django = $django_root_django ? {
      false   => "/${real_name}",
      default => $django_root_django,
    }
    $real_django_static_path = $django_static_path ? {
      false   => '/media',
      default => $django_static_path,
    }
    $real_django_static_django = $django_static_django ? {
      false   => "/${real_name}/media",
      default => $django_static_django,
    }

    kbp_apache_new::vhost_addition { "${full_name}/django":
      content => template("kbp_apache_new/vhost-additions/django");
    }

    file {
      "/srv/django${real_django_root_django}":
        mode    => 775,
        ensure  => directory;
      "/srv/django${real_django_root_django}/dispatch.wsgi":
        content => template("kbp_apache_new/django/dispatch.wsgi"),
        replace => false,
        mode    => 775;
      "/srv/django${real_django_static_django}":
        mode    => 775,
        ensure  => directory;
    }
  }

  if $php {
    case $php {
      # Mod_php, I choose you!
      'mod_php': {
        include kbp_apache_new::php
      }
      # Default to CGI
      default:   {
        kbp_apache_new::php_cgi { $full_name:
          documentroot   => $real_documentroot,
          custom_php_ini => $custom_php_ini;
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
}

define kbp_apache_new::module ($ensure = "enable") {
  gen_apache::module { $name:
    ensure => $ensure;
  }
}

define kbp_apache_new::forward_vhost ($forward, $address = '*', $address6 = '::', $ensure="present", $serveralias=false, $statuscode=301, $port=80, $monitor_ip = false, $preserve_path=true) {
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

  kbp_icinga::site { "${name}_forward":
    service_description => "Vhost ${name} forward",
    host_name           => $name,
    address             => $monitor_ip ? {
      false   => $address ? {
        '*'     => false,
        default => $address,
      },
      default => $monitor_ip,
    },
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

define kbp_apache_new::vhost_addition($ensure="present", $content=false) {
  $fullname = regsubst($name,'^(.*?)_.*$','\1')
  $port     = regsubst($name,'^.*_(.*?)/.*$','\1')

  if defined(Kbp_apache_new::Forward_vhost[$fullname]) and $port == 80 {
    fail("kbp_apache_new::vhost_addition ${name} is inconsistent as a forward is in place for this site.")
  }

  gen_apache::vhost_addition { $name:
    ensure  => $ensure,
    content => $content ? {
      false   => undef,
      default => $content,
    };
  }
}

define kbp_apache_new::glassfish_domain($site, $site_port, $connector_port, $connector_loglevel="info") {
  include kbp_apache_new::glassfish_domain_base

  kbp_apache_new::vhost_addition { "${site}_${site_port}/glassfish-jk":
    content => "JkLogLevel ${connector_loglevel}\nJkMount /* ${name}\n";
  }

  concat::add_content {
    "1 worker domain ${name}":
      content   => "${name},",
      linebreak => false,
      target    => "/etc/apache2/workers.properties";
    "3 worker domain ${name} settings":
      content => template("kbp_apache_new/glassfish/workers.properties_settings"),
      target  => "/etc/apache2/workers.properties";
  }
}

define kbp_apache_new::cgi($documentroot=false, $custom_php_ini=false) {
  include gen_base::libapache2-mod-fcgid

  kbp_apache_new::vhost_addition { "${name}/enable-cgi":
    content => template("kbp_apache_new/vhost-additions/enable_cgi");
  }
}
