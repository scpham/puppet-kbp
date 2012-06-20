# Author: Kumina bv <support@kumina.nl>

# Class: kbp_munin::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client {
  include munin::client
  if $munin_proxy and !$munin_proxy_port {
    fail("Kbp_munin::Client: \$munin_proxy set but no \$munin_proxy_port in site.pp")
  }
  if !$munin_proxy and $munin_proxy_port {
    fail("Kbp_munin::Client: \$munin_proxy_port set but no \$munin_proxy in site.pp")
  }

  package { "libnet-snmp-perl":; }

  gen_munin::client::plugin::config { "files_user_plugin":
    section => "files_user_*",
    content => "user root";
  }

  Kbp_ferm::Rule <<| tag == "general_trending" |>>

  if $munin_proxy {
    $munin_template = "kbp_munin/munin.conf_client_with_proxy"
  } else {
    $real_ipaddress = $external_ipaddress ? {
      undef => $ipaddress,
      false => $ipaddress,
      default => $external_ipaddress,
    }
    $munin_template = "kbp_munin/munin.conf_client"
  }

  @@concat::add_content { "2 ${fqdn}":
    content => template($munin_template),
    target  => "/etc/munin/munin-${environment}.conf",
    tag     => "munin_client";
  }
}

# Class: kbp_munin::client::activemq
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::activemq {
  include kbp_munin::client

  gen_munin::client::plugin { ["activemq_size", "activemq_subscribers", "activemq_traffic"]:
    script_path => "/usr/share/munin/plugins/kumina",
    script      => "activemq_";
  }
}

# Class: kbp_munin::client::drbd
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::drbd {
  include kbp_munin::client

  gen_munin::client::plugin { ["drbd_net_0", "drbd_disk_0"]:
    script_path => "/usr/share/munin/plugins/kumina",
    script      => "drbd_";
  }
}

# Class: kbp_munin::client::apache
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::apache {
  # This class is should be included in kbp_apache to collect apache data for munin
  include kbp_munin::client
  include gen_base::libwww-perl

  file { "/etc/apache2/conf.d/server-status":
    content => template("kbp_munin/server-status"),
    require => Package["apache2"],
    notify  => Exec["reload-apache2"];
  }

  gen_munin::client::plugin {
    "apache_accesses":;
    "apache_processes":;
    "apache_volume":;
  }
}

# Class: kbp_munin::client::haproxy
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::haproxy {
  include kbp_munin::client

  gen_munin::client::plugin { ["haproxy_check_duration","haproxy_errors","haproxy_sessions","haproxy_volume"]:
    script_path => "/usr/share/munin/plugins/kumina",
  }

  gen_munin::client::plugin::config { "haproxy_":
    section => "haproxy_*",
    content => "user root\nenv.socket /var/run/haproxy.sock";
  }
}

# Class: kbp_munin::client::icinga
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::icinga {
  include kbp_munin::client

  gen_munin::client::plugin { ["icinga_multi_hosts","icinga_multi_services","icinga_multi_checks"]:
    script_path => "/usr/share/munin/plugins/kumina",
    script      => "icinga_multi_";
  }

  gen_munin::client::plugin::config { "icinga_multi_":
    section => "icinga_multi_*",
    content => "user root";
  }
}

# Class: kbp_munin::client::puppetmaster
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::puppetmaster {
  include kbp_munin::client

  gen_munin::client::plugin {
    ["puppet_nodes","puppet_totals"]:
      script_path => "/usr/share/munin/plugins/kumina",
      script      => "puppet_";
  }

  gen_munin::client::plugin::config { "puppet_":
    section => "puppet_*",
    content => "user root\nenv.num_minutes 60,360";
  }
}

# Class: kbp_munin::client::mysql
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::mysql {
  include kbp_munin::client

  if versioncmp($lsbdistrelease, 6) >= 0 {
    package {"libcache-cache-perl":
      ensure => latest;
    }

    munin_mysql {["bin_relay_log","commands","connections",
      "files_tables","innodb_bpool","innodb_bpool_act",
      "innodb_insert_buf","innodb_io","innodb_io_pend",
      "innodb_log","innodb_rows","innodb_semaphores",
      "innodb_tnx","myisam_indexes","network_traffic",
      "qcache","qcache_mem","replication","select_types",
      "slow","sorts","table_locks","tmp_tables"]:;
    }

    # Remove the old plugins, since they error for strange reasons
    file { ["/etc/munin/plugins/mysql_bytes","/etc/munin/plugins/mysql_innodb",
      "/etc/munin/plugins/mysql_queries","/etc/munin/plugins/mysql_threads",
      "/etc/munin/plugins/mysql_slowqueries"]:
      ensure => absent,
      notify => Service["munin-node"],
    }
  } elsif versioncmp($lsbdistrelease, 6) < 0 {
    gen_munin::client::plugin { ["mysql_bytes","mysql_innodb","mysql_queries","mysql_slowqueries","mysql_threads"]:;  }
  }

  define munin_mysql {
    gen_munin::client::plugin { "mysql_${name}":
      script => "mysql_";
    }
  }
}

# Class: kbp_munin::client::nfs
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::nfs {
  include kbp_munin::client

  gen_munin::client::plugin { "nfs_client":; }
}

# Class: kbp_munin::client::nfsd
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::nfsd {
  include kbp_munin::client

  gen_munin::client::plugin { "nfsd":; }
}

# Class: kbp_munin::client::ntpd
#
# Actions:
#  Setup trending for ntpd.
#
# Depends:
#  kbp_munin::client
#  gen_munin::client::plugin
#  gen_puppet
#
class kbp_munin::client::ntpd {
  include kbp_munin::client

  gen_munin::client::plugin { ["ntp_kernel_err","ntp_kernel_pll_freq","ntp_kernel_pll_off","ntp_offset"]:; }
}

# Class: kbp_munin::client::postgresql
#
# Actions:
#  Setup trending of PostgreSQL.
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::postgresql {
  include kbp_munin::client

  gen_munin::client::plugin { ["postgres_bgwriter","postgres_checkpoints","postgres_connections_db","postgres_users","postgres_xlog"]:; }

  gen_munin::client::plugin::config { "postgres_*":
    content => "user postgres",
  }

  kbp_munin::client::postgresql_dbs { "ALL":; }
}

# Define: kbp_munin::client::postgresql_dbs
#
# Actions:
#  Setup trending of PostgreSQL databases. Requires the settings from kbp_munin::client::postgresql.
#
# Parameters:
#  name
#   The database to setup trending for.
#
# Depends:
#  kbp_munin::client::postgresql
#  gen_puppet
#
define kbp_munin::client::postgresql_dbs {
  include kbp_munin::client::postgresql

  if $name != 'template0' and $name != 'template1' {
    gen_munin::client::plugin {
      "postgres_cache_${name}":
        script => "postgres_cache_";
      "postgres_locks_${name}":
        script => "postgres_locks_";
      "postgres_querylength_${name}":
        script => "postgres_querylength_";
      "postgres_scans_${name}":
        script => "postgres_scans_";
      "postgres_size_${name}":
        script => "postgres_size_";
      "postgres_transactions_${name}":
        script => "postgres_transactions_";
      "postgres_tuples_${name}":
        script => "postgres_tuples_";
    }
  }
}

# Class: kbp_munin::client::bind9
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::bind9 {
  include kbp_munin::client

  gen_munin::client::plugin { "bind9_rndc":; }

  gen_munin::client::plugin::config { "bind9_rndc":
    content => "env.querystats /var/cache/bind/named.stats\nuser bind",
  }
}

# Class: kbp_munin::client::unbound
#
# Actions:
#  setup trending for unbound
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::client::unbound {
  include kbp_munin::client

  gen_munin::client::plugin { ["unbound_hits", "unbound_queue", "unbound_memory", "unbound_by_type", "unbound_by_opcode", "unbound_by_rcode", "unbound_by_flags", "unbound_histogram"]:
    script_path => "/usr/share/munin/plugins/kumina",
    script      => "unbound_";
  }

  gen_munin::client::plugin::config { "unbound":
    section => "unbound*",
    content => "user root\nenv.statefile /tmp/munin-unbound-state\nenv.unbound_conf /etc/unbound/unbound.conf\nenv.unbound_control /usr/sbin/unbound-control\nenv.spoof_warn 1000\nenv.spoof_crit 100000",
  }
}

# Define: kbp_munin::client::glassfish
#
# Actions:
#  Setup the munin trending for glassfish domains
#
# Depends:
#  kbp_munin::client
#  gen_puppet
#
define kbp_munin::client::glassfish ($jmxport, $jmxuser=false, $jmxpass=false) {
  include kbp_munin::client

  kbp_munin::client::jmxcheck { ["${name}_${jmxport}_java_threads", "${name}_${jmxport}_java_process_memory", "${name}_${jmxport}_java_cpu"]:
      jmxuser => $jmxuser,
      jmxpass => $jmxpass;
  }

  # GC plugin doesn't work glassfish
  file { ["/etc/munin/plugins/${name}_${jmxport}_gc_collectioncount", "/etc/munin/plugins/${name}_${jmxport}_gc_collectiontime"]:
    ensure => absent;
  }
}

# Define: kbp_munin::client::jmxcheck
#
# Actions:
#  install the link with the right name in /etc/munin/plugins using gen_munin::client::plugin { }
#
# Depends:
#  gen_puppet
#  gen_munin::client
#
define kbp_munin::client::jmxcheck ($jmxuser=false, jmxpass=false){
  include gen_base::jmxquery

  gen_munin::client::plugin { "jmx_${name}":
    script_path => "/usr/share/munin/plugins/kumina",
    script      => "jmx_",
    require     => Package["jmxquery","munin-plugins-kumina"];
  }

  if $jmxuser {
    gen_munin::client::plugin::config { "jmx_${name}":
      content => "env.jmxuser ${jmxuser}\nenv.jmxpass ${jmxpass}";
    }
  }
}

# Class: kbp_munin::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_munin::server($site, $port=443) inherits munin::server {
  include kbp_nsca::client

  $ssl = $port ? {
    443 => true,
    80  => false,
  }

  kbp_ferm::rule { "Munin connections from ${fqdn}":
    saddr    => $fqdn,
    proto    => "tcp",
    dport    => "4949",
    action   => "ACCEPT",
    exported => true,
    ferm_tag => "general_trending";
  }

  File <| title == "/etc/munin/munin.conf" |> {
    ensure  => absent,
  }

  File <| title == "/etc/cron.d/munin" |> {
    ensure  => absent,
  }

  File <| title == "/etc/send_nsca.cfg" |> {
    mode    => 640,
    group   => "munin",
    require +> Package["munin"],
  }

  package { "rsync":; }

  # The RRD files for Munin are stored on a memory backed filesystem, so
  # sync it to disk on reboots.
  file { "/etc/init.d/munin-server":
    content => template("munin/server/init.d/munin-server"),
    mode    => 755,
    require => [Package["rsync"], Package["munin"]],
  }

  service { "munin-server":
    enable  => true,
    require => File["/etc/init.d/munin-server"],
  }

  exec { "/etc/init.d/munin-server start":
    unless  => "/bin/sh -c '[ -d /dev/shm/munin ]'",
    require => Service["munin-server"];
  }

  # Cron job which syncs the RRD files to disk every 30 minutes.
  file { "/etc/cron.d/munin-sync":
    content => template("munin/server/cron.d/munin-sync"),
    require => [Package["munin"], Package["rsync"]];
  }

  @@kbp_dashboard::customer_entry_export { "Munin":
    path      => "munin",
    entry_url => $ssl ? {
      false => "http://munin.kumina.nl",
      true  => "https://munin.kumina.nl",
    },
    text      => "Graphs of server usage and performance.";
  }

  Kbp_munin::Environment <<| |>> {
    site => $site,
  }
  Kbp_munin::Alert <<| |>>
  Concat::Add_content <<| tag == "munin_client" |>>
}

define kbp_munin::environment($site,$offset=false,$sync_offset=false) {
  service { "munin-${name}":
    require => File["/etc/init.d/munin-${name}","/dev/shm/munin-${name}"];
  }

  if $offset {
    $real_offset = $offset
  } else {
    $real_offset = fqdn_rand(5)
  }

  # Additional check
  if $real_offset > 4 or $real_offset < 0 {
    fail("Offset minute must be between 0 and 4.")
  }

  if $sync_offset {
    $real_sync_offset1 = $sync_offset
    $real_sync_offset2 = $sync_offset+30
  } else {
    $real_sync_offset1 = fqdn_rand(30)
    $real_sync_offset2 = $real_sync_offset1+30
  }

  # Additional check
  if $real_sync_offset1 > 29 or $real_sync_offset1 < 0 {
    fail("Sync offset minute must be between 0 and 4.")
  }

  file {
    "/etc/init.d/munin-${name}":
      mode    => 755,
      content => template("kbp_munin/init-script");
    ["/dev/shm/munin-${name}","/var/log/munin-${name}","/var/run/munin-${name}","/var/lib/munin-${name}"]:
      ensure  => directory,
      owner   => "munin";
    "/srv/www/${site}/${name}":
      ensure  => directory,
      group   => "www-data",
      owner   => "munin";
    "/etc/cron.d/munin-${name}":
      owner   => "root",
      content => template("kbp_munin/cron");
    "/etc/cron.d/munin-sync-${name}":
      owner   => "root",
      content => template("kbp_munin/cron-sync");
    "/etc/logrotate.d/munin-${name}":
      owner   => "root",
      content => template("kbp_munin/logrotate");
  }

  concat {
    "/etc/munin/munin-${name}.conf":
      purge_on_pm => true,
      require     => Package["munin"];
    "/srv/www/${site}/${name}/.htpasswd":
      require     => File["/srv/www/${site}/${name}"];
  }

  concat::add_content { "0 ${name} base":
    content => template("kbp_munin/munin.conf_base"),
    target  => "/etc/munin/munin-${name}.conf";
  }

  kbp_apache_new::vhost_addition { "${site}_${port}/access_${name}":
    content => template("kbp_munin/vhost-additions/access");
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${site}/${name}/.htpasswd",
  }
}

define kbp_munin::alert_export($command) {
  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  @@kbp_munin::alert { "${name}_${environment}":
    alert_name  => $sanitized_name,
    command     => $command,
    environment => $environment;
  }
}

define kbp_munin::alert($alert_name, $command, $environment) {
  concat::add_content { "1 $name":
    content => template("kbp_munin/munin.conf_alert"),
    target  => "/etc/munin/munin-${environment}.conf";
  }
}

#
# Class: kbp_munin::two::server
#
# Actions:
#  - Install munin (through gen_munin::server)
#  - Install and setup apache
#  - Install and setup rrdcached (when requested)
#
# Parameters:
#  site:
#   The name the munin graphs are hosted on
#  wildcard:
#   The wildcard certificate name (there is no support for separate ssl certs for now)
#  intermediate:
#   The intermediate certificate
#  use_rrdcached:
#   Use rrdcached to cache all writes to RRD
#  allowed_access_to_root:
#   By default, access to the root of the site (the overview) is disallowed. When this parameter is set,
#   the people in it's environment are allowed access to the root and are able to see an overview of all machines.
#
# Depends:
#  gen_munin::server
#  kbp_munin::two
#
class kbp_munin::two::server ($site, $wildcard=false, $intermediate=false, $use_rrdcached=true, $allowed_access_to_root='kumina'){
  include gen_munin::server

  if $wildcard {
    $port = 443
    include kbp_apache_new::ssl
  } else {
    $port = 80
  }

  file {
    '/etc/munin/munin.conf':
      content => template('kbp_munin/2/munin.conf'),
      require => Package['munin'];
    '/etc/munin/conf':
      ensure => directory,
      require => Package['munin'];
    '/etc/apache2/conf.d/munin':
      ensure => absent,
      require => Package['munin'],
      notify => Exec['reload-apache2'];
  }

  kbp_apache_new::site { $site:
    address      => $ipaddress,
    make_default => true,
    wildcard     => $wildcard,
    intermediate => $intermediate;
  }

  kbp_apache_new::vhost_addition {
    "${site}_${port}/munin.conf":
      content => template("kbp_munin/2/apache2/munin.conf");
    # Configure access to the root web-dir
    "${site}_${port}/access_0_common":
      content => template("kbp_munin/2/apache2/access_common");
  }

  kbp_apache_new::cgi { "${site}_${port}":; }

  File <| title == "/srv/www/${site}" |> {
    mode => 775,
  }

  setfacl { "/srv/www/${site} munin access":
    acl          => "group:munin:rwx",
    dir          => "/srv/www/${site}",
    make_default => true,
    require      => [Kbp_apache_new::Site[$site],Package['munin']];
  }

  if $use_rrdcached {
    # rrdcached makes for less IO on the machine
    kservice {"rrdcached":
      hasreload => false;
    }
    group { "rrdcached":
      system => true,
      ensure => present;
    }
    user { ["www-data", "munin"]:
      groups  => "rrdcached",
      require => [Package["munin","apache2"], Group["rrdcached"]];
    }
    file { "/etc/default/rrdcached":
      content => template("kbp_munin/2/rrdcached.default"),
      require => Package["rrdcached"],
      notify  => Exec["reload-rrdcached"];
    }
  }
}

#
# Define: kbp_munin::two::environment
#
# Actions:
#  - Add apache config for the environment
#  - Import htpasswd info
#  - Export config for the clients
#
# Depends:
#  gen_puppet
#
define kbp_munin::two::environment ($site,$port,$prettyname=false) {
  $pretty_name = $prettyname ? {
    false   => $sanitized_customer_name,
    default => $prettyname,
  }

  gen_munin::environment{$name:;}

  kbp_apache_new::vhost_addition { "${site}_${port}/access_${name}":
    content => template("kbp_munin/2/apache2/access.conf");
  }

  concat { "/srv/www/${site}/.htpasswd_${name}":
    require => File["/srv/www/${site}"];
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${site}/.htpasswd_${name}",
  }

  kbp_ferm::rule { "Munin connections for ${name}":
    saddr    => $ipaddress,
    proto    => "tcp",
    dport    => "4949",
    action   => "ACCEPT",
    exported => true,
    ferm_tag => "trending_${name}";
  }
}

#
# Class: kbp_munin::two::client
#
# Actions: Install munin-node (through gen_munin) and import config
#
# Depends:
#  kbp_munin::two
#  gen_munin::client
#
class kbp_munin::two::client {
  include gen_munin::client

  package { 'munin-plugins-kumina':
    ensure => latest;
  }

  Kbp_ferm::Rule <<| tag == "trending_${environment}" |>>
}
