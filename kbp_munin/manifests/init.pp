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
class kbp_munin::client inherits munin::client {
  if $munin_proxy and !$munin_proxy_port {
    fail("Kbp_munin::Client: \$munin_proxy set but no \$munin_proxy_port in site.pp")
  }
  if !$munin_proxy and $munin_proxy_port {
    fail("Kbp_munin::Client: \$munin_proxy_port set but no \$munin_proxy in site.pp")
  }

  kpackage { "libnet-snmp-perl":; }

  munin::client::plugin::config { "files_user_plugin":
    section => "files_user_*",
    content => "user root";
  }

  Kbp_ferm::Rule <<| tag == "general_trending" |>>

  @@concat::add_content { "2 ${fqdn}":
    content => template("kbp_munin/munin.conf_client"),
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

  munin::client::plugin { ["activemq_size", "activemq_subscribers", "activemq_traffic"]:
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

  munin::client::plugin { ["drbd_net_0", "drbd_disk_0"]:
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

  munin::client::plugin {
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

  munin::client::plugin { ["haproxy_check_duration","haproxy_errors","haproxy_sessions","haproxy_volume"]:
    script_path => "/usr/local/share/munin/plugins",
  }

  munin::client::plugin::config { "haproxy_":
    section => "haproxy_*",
    content => "user root\nenv.socket /var/run/haproxy.sock";
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

  munin::client::plugin {
    ["puppet_nodes","puppet_totals"]:
      script_path => "/usr/share/munin/plugins/kumina",
      script      => "puppet_";
  }

  munin::client::plugin::config { "puppet_":
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
    kpackage {"libcache-cache-perl":
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
    munin::client::plugin { ["mysql_bytes","mysql_innodb","mysql_queries","mysql_slowqueries","mysql_threads"]:;  }
  }

  define munin_mysql {
    munin::client::plugin { "mysql_${name}":
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

  munin::client::plugin { "nfs_client":; }
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

  munin::client::plugin { "nfsd":; }
}

# Class: kbp_munin::client::ntpd
#
# Actions:
#  Setup trending for ntpd.
#
# Depends:
#  kbp_munin::client
#  munin::client::plugin
#  gen_puppet
#
class kbp_munin::client::ntpd {
  include kbp_munin::client

  munin::client::plugin { ["ntp_kernel_err","ntp_kernel_pll_freq","ntp_kernel_pll_off","ntp_offset"]:; }
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

  munin::client::plugin { "bind9_rndc":; }

  munin::client::plugin::config { "bind9_rndc":
    content => "env.querystats /var/cache/bind/named.stats\nuser bind",
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
define kbp_munin::client::glassfish ($jmxport) {
  include kbp_munin::client

  kbp_munin::client::jmxcheck {
    "${name}_${jmxport}_java_threads":;
    "${name}_${jmxport}_java_process_memory":;
    "${name}_${jmxport}_java_cpu":;
    "${name}_${jmxport}_gc_collectioncount":;
    "${name}_${jmxport}_gc_collectiontime":;
  }
}

# Define: kbp_munin::client::jmxcheck
#
# Actions:
#  install the link with the right name in /etc/munin/plugins using munin::client::plugin { }
#
# Depends:
#  gen_puppet
#  munin::client
#
define kbp_munin::client::jmxcheck {
  include gen_base::jmxquery

  munin::client::plugin { "jmx_${name}":
    script_path => "/usr/bin",
    script      => "jmx_",
    require     => Package["jmxquery"];
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
    require +> Kpackage["munin"],
  }

  kpackage { "rsync":; }

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

define kbp_munin::environment($site) {
  service { "munin-${name}":
    require => File["/etc/init.d/munin-${name}","/dev/shm/munin-${name}"];
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
