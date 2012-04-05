# Author: Kumina bv <support@kumina.nl>

# Class: kbp_icinga::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::client {
  include gen_icinga::client
  include gen_base::python-argparse

  Kbp_ferm::Rule <<| tag == "general_monitoring" |>>
  Kbp_ferm::Rule <<| tag == "general_monitoring_${environment}" |>>

  kbp_icinga::clientcommand {
    "check_3ware":
      sudo      => true;
    "check_adaptec":
      sudo      => true;
    "check_arpwatch":
      command   => "check_procs",
      arguments => "-c 1: -C arpwatch";
    "check_asterisk":
      sudo      => true,
      command   => "check_asterisk",
      arguments => "signet";
    "check_backup_status":
      command   => "check_procs",
      arguments => "-w 0 -C rdiff-backup";
    "check_cassandra":;
    "check_cpu":
      arguments => "-w 90 -c 95";
    "check_dhcp":
      command   => "check_procs",
      arguments => $lsbdistcodename ? {
        "lenny" => "-c 1: -C dhcpd3",
        default => "-c 1: -C dhcpd",
      };
    "check_disk_space":
      sudo      => true,
      command   => "check_disk",
      arguments => "-W 10% -K 5% -w 10% -c 5% -l --errors-only -t 20";
    "check_dnszone":
      arguments => '$ARG1$ $ARG2$';
    "check_drbd":
      arguments => "-d All";
    "check_drbd_mount":
      sudo      => true,
      command   => "check_file",
      arguments => '-f $ARG1$ -c $ARG2$';
    "check_dummy":
      arguments => '$ARG1$';
    "check_ferm_config":
      sudo      => true,
      arguments => '$ARG1$';
    "check_heartbeat":;
    "check_icinga_config":
      sudo      => true,
      arguments => '$ARG1$';
    "check_java_heap_usage":
      command   => "check_javaheapusage",
      arguments => '/etc/munin/plugins/jmx_$ARG1$_java_process_memory 96 93';
    "check_ksplice":
      command   => "check_uptrack_local",
      arguments => "-w i -c o";
    "check_loadtrend":
      arguments => "-m 1.5 -c 5 -w 2.5";
    "check_local_smtp":
      command   => "check_smtp",
      arguments => "-H 127.0.0.1";
    "check_mbean_value":
      arguments => '$ARG1$ $ARG2$ $ARG3$ $ARG4$';
    "check_mcollective":
      command   => "check_procs",
      arguments => "-c 1:1 -C ruby -a /usr/sbin/mcollectived";
    "check_memory":
      arguments => "-w 6 -c 3";
    "check_mysql":
      arguments => "-u nagios";
    "check_mysql_connlimit":
      sudo      => true,
      arguments => "-w 90 -c 95 -- --defaults-file=/etc/mysql/debian.cnf";
    "check_mysql_slave":
      command   => "check_mysql",
      arguments => "-u nagios -S";
    "check_nfs_client":
      sudo      => true,
      command   => "check_file",
      arguments => '-f $ARG1$ -c $ARG2$';
    "check_ntpd":
      command   => "check_procs",
      arguments => "-c 1: -C ntpd";
    "check_nullmailer":
      sudo      => true;
    "check_open_files":
      arguments => "-w 90 -c 95";
    "check_pacemaker":
      sudo      => true,
      path      => "/usr/sbin/",
      command   => "crm_mon",
      arguments => "-s";
    "check_passenger_queue":
      sudo      => true;
    "check_ping":
      arguments => '-w $ARG1$ -c $ARG2$ -p $ARG3$ -H $ARG4$';
    "check_proc_status":
      sudo      => true,
      arguments => '$ARG1$';
    "check_puppet_dontrun":
      sudo      => true,
      command   => "check_file",
      arguments => '-f $ARG1$ -n';
    "check_puppet_state_freshness":
      sudo      => true,
      command   => "check_puppet",
      arguments => "-w 25000 -c 50000";
    "check_puppet_failures":
      sudo      => true,
      command   => "check_puppet",
      arguments => "-f -w 1 -c 1";
    "check_rabbitmqctl":
      sudo      => true,
      arguments => '-p $ARG1$';
    "check_remote_ntp":
      command   => "check_ntp_time",
      arguments => "-H 0.debian.pool.ntp.org -t 20";
    "check_smtp":
      arguments => "-H 127.0.0.1";
    "check_sslcert":
      sudo      => true,
      arguments => '$ARG1$';
    "check_swap":
      arguments => "-w 10 -c 5";
    "check_zombie_processes":
      command   => "check_procs",
      arguments => "-w 5 -c 10 -s Z";
  }

  gen_icinga::configdir { "${::environment}/${fqdn}":; }

  kbp_icinga::host { "${fqdn}":
    parents => $parent;
  }

  if $is_virtual == "true" {
    kbp_icinga::service { "memory":
      service_description => "Memory usage",
      check_command       => "check_memory",
      max_check_attempts  => 30,
      nrpe                => true,
      warnsms             => false;
    }
  } else {
    kbp_icinga::service { "memory":
      ensure => absent;
    }
  }

  kbp_icinga::service {
    "backup_status":
      service_description => "Backup status",
      check_command       => "check_backup_status",
      max_check_attempts  => 8640,
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
    "ssh":
      service_description => "SSH connectivity",
      check_command       => "check_ssh";
    "disk_space":
      service_description => "Disk space",
      check_command       => "check_disk_space",
      nrpe                => true,
      warnsms             => false;
    "puppet_dontrun":
      service_description => "Puppet dontrun",
      check_command       => "check_puppet_dontrun",
      arguments           => ["/etc/puppet/dontrunpuppetd"],
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
    "puppet_state":
      service_description => "Puppet state freshness",
      check_command       => "check_puppet_state_freshness",
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
    "puppet_failures":
      service_description => "Puppet failures",
      check_command       => "check_puppet_failures",
      max_check_attempts  => 1440,
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
    "cpu":
      ensure              => absent,
      service_description => "CPU usage",
      check_command       => "check_cpu",
      max_check_attempts  => 30,
      nrpe                => true;
    "loadtrend":
      service_description => "Load trend",
      check_command       => "check_loadtrend",
      check_interval      => 300,
      retry_interval      => 60,
      max_check_attempts  => 5,
      nrpe                => true,
      sms                 => false;
    "open_files":
      service_description => "Open files",
      check_command       => "check_open_files",
      nrpe                => true;
    "nrpe":
      service_description => "NRPE port",
      check_command       => "return-ok_nrpe",
      nrpe                => true,
      customer_notify     => false;
    "ntp_offset":
      service_description => "NTP offset",
      check_command       => "check_remote_ntp",
      nrpe                => true,
      check_interval      => 14400,
      retry_interval      => 1800,
      sms                 => false;
    "ntpd":
      service_description => "NTPD",
      check_command       => "check_ntpd",
      nrpe                => true,
      sms                 => false;
    "swap":
      service_description => "Swap usage",
      check_command       => "check_swap",
      nrpe                => true,
      warnsms             => false;
    "zombie_processes":
      service_description => "Zombie processes",
      check_command       => "check_zombie_processes",
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
  }

  gen_icinga::servicedependency { "puppet_dependency_freshness_dontrun":
    dependent_service_description => "Puppet state freshness",
    host_name                     => $fqdn,
    service_description           => "Puppet dontrun",
    execution_failure_criteria    => "c",
    notification_failure_criteria => "c";
  }

  gen_sudo::rule { "Icinga can run all plugins as root":
    entity            => "nagios",
    as_user           => "root",
    password_required => false,
    command           => "/usr/lib/nagios/plugins/";
  }
}

class kbp_icinga::proxyclient($proxy, $proxytag="proxy_${environment}", $saddr=false) {
  if $saddr {
    Kbp_ferm::Rule <<| tag == $proxytag |>> {
      saddr => $saddr,
    }
  } else {
    Kbp_ferm::Rule <<| tag == $proxytag |>>
  }

  Kbp_icinga::Service <| preventproxyoverride != true |> {
    proxy => $proxy,
  }
  Kbp_icinga::Host <| preventproxyoverride != true |> {
    proxy => $proxy,
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

class kbp_icinga::proxy($proxytag="proxy_${environment}") {
  include gen_base::nagios-nrpe-plugin

  file {
    "/etc/nagios/nrpe.d/runcommand.cfg":
      content => 'command[runcommand]=$ARG1$';
    "/etc/default/openbsd-inetd":
      content => "OPTIONS='-R 2560'",
      notify  => Service["openbsd-inetd"];
  }

  kbp_ferm::rule { "NRPE monitoring from ${fqdn}":
    saddr    => $fqdn,
    proto    => "tcp",
    dport    => 5666,
    action   => "ACCEPT",
    exported => true,
    ferm_tag => $proxytag;
  }
}

class kbp_icinga::server($dbpassword, $dbhost="localhost", $ssl=true) {
  include gen_icinga::server
  include kbp_nsca::server

  kpackage { "icinga-web":;}

  gen_logrotate::rotate { "icinga":
    logs => "/var/log/icinga/icinga.log";
  }

  file {
    "/etc/icinga/ido2db.cfg":
      content => template("kbp_icinga/ido2db.cfg"),
      owner   => "nagios",
      mode    => 600,
      require => Package["icinga"],
      notify  => Exec["reload-icinga"];
    "/etc/icinga/modules/idoutils.cfg":
      content => template("kbp_icinga/idoutils.cfg"),
      require => Package["icinga"],
      notify  => Exec["reload-icinga"];
    "/etc/icinga-web/databases.xml":
      content => template("kbp_icinga/icinga-web/databases.xml"),
      owner   => "www-data",
      mode    => 600,
      require => Package["icinga-web"],
      notify  => Exec["clearcache_icinga-web"];
    "/etc/icinga-web/translation.xml":
      content => template("kbp_icinga/icinga-web/translation.xml"),
      require => Package["icinga-web"],
      notify  => Exec["clearcache_icinga-web"];
    "/usr/share/icinga-web/app/config/factories.xml":
      content => template("kbp_icinga/icinga-web/factories.xml"),
      require => Package["icinga-web"],
      notify  => Exec["clearcache_icinga-web"];
    "/etc/default/icinga":
      content => template("kbp_icinga/default_icinga"),
      notify  => Exec["reload-icinga"];
  }

  exec { "clearcache_icinga-web":
    command     => "/usr/share/icinga-web/bin/clearcache.sh",
    refreshonly => true;
  }

  @@mysql::server::db {
    "icinga for ${fqdn}":
        tag => "mysql_kumina";
    "icinga_web for ${fqdn}":
        tag => "mysql_kumina";
  }

  @@mysql::server::grant {
    "icinga on icinga for ${fqdn}":
      user     => "icinga",
      db       => "icinga",
      password => $dbpassword,
      hostname => "%",
      tag      => "mysql_kumina";
    "icinga on icinga_web for ${fqdn}":
      user     => "icinga",
      db       => "icinga_web",
      password => $dbpassword,
      hostname => "%",
      tag      => "mysql_kumina";
  }

  kbp_mysql::client { "icinga":
    mysql_name => "icinga";
  }

  gen_apt::preference { ["icinga","icinga-core","icinga-cgi","icinga-common","icinga-doc","icinga-idoutils"]:; }

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

  Gen_icinga::Servercommand <<| |>>

  kbp_icinga::servercommand {
    ["check_ssh","check_smtp"]:;
    ["check_asterisk","check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd",
     "check_pacemaker","check_mysql","check_mysql_connlimit","check_mysql_slave","check_loadtrend","check_heartbeat","check_ntpd","check_remote_ntp","check_coldfusion","check_dhcp",
     "check_arpwatch","check_3ware","check_adaptec","check_cassandra","check_swap","check_puppet_failures","check_nullmailer","check_passenger_queue","check_mcollective","check_backup_status"]:
      nrpe          => true;
    "return-ok":
      command_name  => "check_dummy",
      host_argument => false,
      arguments     => "0";
    "return-ok_nrpe":
      command_name  => "check_dummy",
      nrpe          => true,
      arguments     => "0";
    "check_drbd_mount":
      command_name  => "check_drbd_mount",
      arguments     => ['$ARG1$','$ARG2$'],
      nrpe          => true;
    "check_ping":
      arguments     => ['-w 5000,100%','-c 5000,100%','-p 1'];
    "check_ping_nrpe":
      command_name  => "check_ping",
      arguments     => ['5000,100%','5000,100%','1','$ARG1$'],
      nrpe          => true;
    "check_ferm_config":
      arguments     => ['$ARG1$'],
      nrpe          => true;
    "check_http":
      arguments     => ['-I $HOSTADDRESS$','-e $ARG1$','-t 20'];
    "check_http_vhost":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-e $ARG2$','-t 20'];
    "check_http_vhost_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_port":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-p $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_response":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-r $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_ssl":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-S','-H $ARG1$','-e $ARG2$','-t 20'];
    "check_http_vhost_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-S','-H $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_url":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-u $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_url_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-u $ARG3$','-e $ARG4$','-t 20'];
    "check_http_vhost_url_ssl":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-S','-H $ARG1$','-u $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_url_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-S','-H $ARG2$','-u $ARG3$','-e $ARG4$','-t 20'];
    "check_http_vhost_url_response":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-u $ARG2$','-r $ARG3$','-e $ARG4$','-t 20'];
    "check_http_vhost_port_url_response":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-p $ARG2$','-u $ARG3$','-r $ARG4$','-e $ARG5$','-t 20'];
    "check_icinga_config":
      arguments     => ['$ARG1$'],
      nrpe          => true;
    "check_mbean_value":
      arguments     => ['$ARG1$','$ARG2$','$ARG3$','$ARG4$'],
      nrpe          => true;
    "check_puppet_dontrun":
      arguments     => ['$ARG1$'],
      nrpe          => true;
    "check_tcp":
      arguments     => '-p $ARG1$';
    "check_nfs_client":
      command_name  => "check_nfs_client",
      arguments     => ['$ARG1$','$ARG2$'],
      nrpe          => true;
    "check_nfs_server":
      command_name  => "check_rpc",
      arguments     => "-C nfs -c2,3";
    "check_sslcert":
      arguments     => '$ARG1$',
      nrpe          => true;
    "check_proc_status":
      arguments     => '$ARG1$',
      nrpe          => true;
    "check_ssl_cert":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ["-t 20",'-H $ARG1$',"-C 30"];
    "check_java_heap_usage":
      arguments     => '$ARG1$',
      nrpe          => true;
    "check_imaps":
      command_name  => "check_imap",
      arguments     => ["-p 993","-S"];
    "check_dnszone":
      arguments     => ['$ARG1$','$ARG2$'],
      nrpe          => true;
    "check_rabbitmqctl":
      arguments => '$ARG1$',
      nrpe      => true;
  }

  file {
    "/etc/icinga/cgi.cfg":
      content => template("kbp_icinga/server/cgi.cfg"),
      notify  => Exec["reload-icinga"],
      require => Package["icinga"];
    "/etc/icinga/icinga.cfg":
      content => template("kbp_icinga/server/icinga.cfg"),
      notify  => Exec["reload-icinga"],
      require => Package["icinga"];
    "/etc/icinga/config":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true,
      require => Package["icinga"],
      notify  => Exec["reload-icinga"];
    "/etc/icinga/config/generic/notify_commands.cfg":
      content => template("kbp_icinga/server/config/generic/notify_commands.cfg"),
      notify  => Exec["reload-icinga"];
  }

  class { "kbp_icinga::icinga_config":
    filename => "/etc/icinga/icinga.cfg";
  }

  setfacl { "Allow www-data to read the command file":
    dir          => "/var/lib/icinga/rw",
    acl          => "group:www-data:rw-",
    make_default => true;
  }

  gen_icinga::configdir { "generic":; }

  kbp_icinga::service {
    "ha_service":
      conf_dir                     => "generic",
      use                          => " ",
      servicegroups                => "ha_services",
      initial_state                => "u",
      obsess_over_service          => "0",
      check_freshness              => "0",
      notifications_enabled        => "1",
      event_handler_enabled        => "0",
      retain_status_information    => "1",
      retain_nonstatus_information => "1",
      is_volatile                  => "0",
      notification_period          => "24x7",
      active_checks_enabled        => "1",
      passive_checks_enabled       => "0",
      flap_detection_enabled       => "1",
      process_perf_data            => "1",
      notification_interval        => "600",
      check_period                 => "24x7",
      check_interval               => "30",
      retry_interval               => "10",
      max_check_attempts           => "3",
      notification_options         => "w,u,c,r",
      register                     => "0";
    "critsms_service":
      conf_dir      => "generic",
      use           => "ha_service",
      servicegroups => "wh_services_critsms",
      register      => "0";
    "warnsms_service":
      conf_dir      => "generic",
      use           => "ha_service",
      servicegroups => "wh_services_warnsms",
      register      => "0";
    "mail_service":
      conf_dir      => "generic",
      use           => "ha_service",
      servicegroups => "mail_services",
      register      => "0";
    "passive_service":
      conf_dir               => "generic",
      use                    => "ha_service",
      servicegroups          => "mail_services",
      active_checks_enabled  => "0",
      passive_checks_enabled => "1",
      check_command          => "return-ok",
      register               => "0";
  }

  kbp_icinga::host {
    "ha_host":
      conf_dir                     => "generic",
      use                          => " ",
      hostgroups                   => "ha_hosts",
      initial_state                => "u",
      notifications_enabled        => "1",
      event_handler_enabled        => "0",
      flap_detection_enabled       => "1",
      process_perf_data            => "1",
      retain_status_information    => "1",
      retain_nonstatus_information => "1",
      check_interval               => "10",
      notification_period          => "24x7",
      notification_interval        => "600",
      max_check_attempts           => "3",
      register                     => "0";
    "wh_host":
      conf_dir   => "generic",
      use        => "ha_host",
      hostgroups => "wh_hosts",
      register   => "0";
    "mail_host":
      conf_dir   => "generic",
      use        => "ha_host",
      hostgroups => "mail_hosts",
      register   => "0";
  }

  gen_icinga::timeperiod {
    "24x7":
      conf_dir  => "generic",
      tp_alias  => "24 hours a day, 7 days a week",
      monday    => "00:00-24:00",
      tuesday   => "00:00-24:00",
      wednesday => "00:00-24:00",
      thursday  => "00:00-24:00",
      friday    => "00:00-24:00",
      saturday  => "00:00-24:00",
      sunday    => "00:00-24:00";
    "workhours":
      conf_dir  => "generic",
      tp_alias  => "Kumina bv work hours",
      monday    => "08:00-18:00",
      tuesday   => "08:00-18:00",
      wednesday => "08:00-18:00",
      thursday  => "08:00-18:00",
      friday    => "08:00-18:00";
  }

  gen_icinga::hostgroup {
    "ha_hosts":
      conf_dir => "generic",
      hg_alias => "High availability servers";
    "wh_hosts":
      conf_dir => "generic",
      hg_alias => "Workhours availability servers";
    "mail_hosts":
      conf_dir => "generic",
      hg_alias => "Mail only servers";
  }

  gen_icinga::servicegroup {
    "ha_services":
      conf_dir => "generic",
      sg_alias => "High availability services";
    "wh_services_critsms":
      conf_dir => "generic",
      sg_alias => "Workhours availability services, sms on Crit only";
    "wh_services_warnsms":
      conf_dir => "generic",
      sg_alias => "Workhours availability services, sms on Warn and Crit";
    "mail_services":
      conf_dir => "generic",
      sg_alias => "Mail alert only services";
  }

  gen_icinga::contactgroup {
    "devnull":
      conf_dir => "generic",
      cg_alias => "No notify contacts";
    "generic_email":
      conf_dir => "generic",
      cg_alias => "Generic contacts";
  }

  gen_icinga::contact {
    "devnull":
      conf_dir                      => "generic",
      c_alias                       => "No notify contact",
      contactgroups                 => "devnull",
      host_notifications_enabled    => 0,
      service_notifications_enabled => 0,
      contact_data                  => false;
    "generic_email":
      conf_dir      => "generic",
      c_alias       => "Generic email",
      contactgroups => "generic_email",
      contact_data  => false;
  }

  concat { "/etc/icinga/htpasswd.users":; }

  Concat::Add_content <<| tag == "htpasswd" |>> {
    target => "/etc/icinga/htpasswd.users",
  }

  file {
    "/usr/bin/icinga-check-alive":
      content => template("kbp_icinga/server/icinga-check-alive"),
      mode    => 755;
  }

  kcron { "icinga-check-alive":
    minute => "*/5",
    command => "/usr/bin/icinga-check-alive";
  }

  @@kbp_munin::alert_export { "icinga on ${fqdn}":
    command => "/usr/sbin/send_nsca -H ${fqdn} -c /etc/send_nsca.cfg";
  }

  @@kbp_dashboard::customer_entry_export { "Icinga on ${fqdn}":
    path            => "icinga",
    regex_paths     => ["/cgi-bin/icinga/","/stylesheets/","/images/"],
    entry_url       => $ssl ? {
      false => "http://icinga.kumina.nl",
      true  => "https://icinga.kumina.nl",
    },
    text            => "Availability monitoring of servers and services.",
    add_environment => false;
  }
}

# Class: kbp_icinga::environment
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::environment {
  if ! $monitoring_sms {
    Kbp_icinga::Service <| |> {
      sms => false,
    }
    Kbp_icinga::Host <| |> {
      sms => false,
    }
  }

  gen_icinga::configdir { ["${::environment}","${::environment}/generic"]:; }

  gen_icinga::contactgroup { "${::environment}_email":
    conf_dir => "${::environment}/generic",
    cg_alias => "${::environment} contacts";
  }

  gen_icinga::contact { "${::environment}":
    conf_dir      => "${::environment}/generic",
    c_alias       => "${::environment} email",
    contactgroups => "${::environment}_email",
    contact_data  => false;
  }

  gen_icinga::hostgroup { "${::environment}_hosts":
    conf_dir => "${::environment}/generic",
    hg_alias => "${::environment} servers";
  }

  gen_icinga::hostescalation { "${::environment}_mail":
    conf_dir              => "${::environment}/generic",
    hostgroup_name        => "${::environment}_hosts",
    first_notification    => 1,
    last_notification     => 1,
    notification_interval => 600,
    escalation_period     => "24x7",
    contact_groups        => "${::environment}_email";
  }

  gen_icinga::servicegroup { "${::environment}_services":
    conf_dir => "${::environment}/generic",
    sg_alias => "${::environment} services";
  }

  gen_icinga::serviceescalation { "${::environment}_mail":
    conf_dir              => "${::environment}/generic",
    servicegroup_name     => "${::environment}_services",
    first_notification    => 1,
    last_notification     => 1,
    notification_interval => 600,
    escalation_period     => "24x7",
    contact_groups        => "${::environment}_email";
  }

  kbp_icinga::service {
    "ha_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      servicegroups                => "ha_services,${::environment}_services",
      initial_state                => "u",
      obsess_over_service          => "0",
      check_freshness              => "0",
      notifications_enabled        => "1",
      event_handler_enabled        => "0",
      retain_status_information    => "1",
      retain_nonstatus_information => "1",
      is_volatile                  => "0",
      notification_period          => "24x7",
      active_checks_enabled        => "1",
      passive_checks_enabled       => "0",
      flap_detection_enabled       => "1",
      process_perf_data            => "1",
      notification_interval        => "600",
      check_period                 => "24x7",
      check_interval               => "10",
      retry_interval               => "10",
      max_check_attempts           => "3",
      notification_options         => "w,u,c,r",
      register                     => "0";
    "critsms_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_service",
      servicegroups                => "wh_services_critsms,${::environment}_services",
      register                     => "0";
    "warnsms_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_service",
      servicegroups                => "wh_services_warnsms,${::environment}_services",
      register                     => "0";
    "mail_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_service",
      servicegroups                => "mail_services,${::environment}_services",
      register                     => "0";
    "passive_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_service",
      servicegroups                => "mail_services,${::environment}_services",
      active_checks_enabled        => "0",
      passive_checks_enabled       => "1",
      check_command                => "return-ok",
      register                     => "0";
  }

  kbp_icinga::host {
    "ha_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      hostgroups                   => "ha_hosts,${::environment}_hosts",
      initial_state                => "u",
      notifications_enabled        => "1",
      event_handler_enabled        => "0",
      flap_detection_enabled       => "1",
      process_perf_data            => "1",
      retain_status_information    => "1",
      retain_nonstatus_information => "1",
      check_interval               => "10",
      notification_period          => "24x7",
      notification_interval        => "600",
      max_check_attempts           => "3",
      register                     => "0";
    "wh_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_host",
      hostgroups                   => "wh_hosts,${::environment}_hosts",
      register                     => "0";
    "mail_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "ha_host",
      hostgroups                   => "mail_hosts,${::environment}_hosts",
      register                     => "0";
  }
}

# Class: kbp_icinga::ferm_config
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::ferm_config($filename) {
  kbp_icinga::service { "ferm_config":
    service_description => "Ferm configuration ${filename}",
    check_command       => "check_ferm_config",
    arguments           => $filename,
    check_interval      => 900,
    nrpe                => true;
  }
}

# Class: kbp_icinga::ferm_config
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::ksplice {
  kbp_icinga::service { "ksplice":
    service_description => "Ksplice update status",
    check_command       => "check_ksplice",
    nrpe                => true,
    sms                 => false,
    customer_notify     => false;
  }
}

# Class: kbp_icinga::heartbeat
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::heartbeat {
  kbp_icinga::service { "heartbeat":
    service_description => "Heartbeat",
    check_command       => "check_heartbeat",
    nrpe                => true;
  }
}

# Class: kbp_icinga::icinga_config
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::icinga_config($filename) {
  kbp_icinga::service { "icinga_config":
    service_description => "Icinga configuration ${filename}",
    check_command       => "check_icinga_config",
    arguments           => $filename,
    check_interval      => 900,
    nrpe                => true,
    sms                 => false;
  }
}

# Class: kbp_icinga::nfs::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::nfs::server {
  kbp_icinga::service { "nfs_daemon":
    service_description => "NFS daemon",
    check_command       => "check_nfs_server";
  }
}

# Class: kbp_icinga::nullmailer
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::nullmailer {
  include gen_base::python-argparse

  kbp_icinga::service { "nullmailer":
    service_description => "Nullmailer queue",
    check_command       => "check_nullmailer",
    nrpe                => true,
    sms                 => false;
  }
}

# Class: kbp_icinga::passenger::queue
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::passenger::queue {
  kbp_icinga::service { "passenger_queue":
    service_description => "Passenger queue",
    check_command       => "check_passenger_queue",
    nrpe                => true,
    warnsms             => false;
  }
}

# Class: kbp_icinga::dhcp
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::dhcp {
  kbp_icinga::service { "dhcp_daemon":
    service_description => "DHCP daemon",
    check_command       => "check_dhcp",
    nrpe                => true;
  }
}

# Class: kbp_icinga::cassandra
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::cassandra {
  kbp_icinga::service { "cassandra":
    service_description => "Cassandra status",
    check_command       => "check_cassandra",
    nrpe                => true;
  }
}

# Class: kbp_icinga::asterisk
#
# Actions:
#  Set up asterisk monitoring
#
class kbp_icinga::asterisk {
  kbp_icinga::service { "asterisk":
    service_description => "Asterisk status",
    check_command       => "check_asterisk",
    nrpe                => true;
  }
}

# Class: kbp_icinga::mcollective
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::mcollective {
  kbp_icinga::service { "mcollectived":
    service_description => "MCollective daemon",
    check_command       => "check_mcollective",
    check_interval      => "1800",
    sms                 => false,
    nrpe                => true,
    customer_notify     => false;
  }
}

define kbp_icinga::clientcommand($sudo=false, $path=false, $command=false, $arguments=false) {
  file { "/etc/nagios/nrpe.d/${name}.cfg":
    content => template("kbp_icinga/clientcommand"),
    require => Package["nagios-nrpe-server"];
  }
}

# Define: kbp_icinga::service
#
# Parameters:
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::service($ensure="present", $service_description=false, $use=false, $servicegroups=false, $passive=false, $ha=false, $sms=true,
    $warnsms=true, $conf_dir="${::environment}/${::fqdn}", $host_name=$::fqdn, $initial_state=false, $active_checks_enabled=false, $passive_checks_enabled=false,
    $obsess_over_service=false, $check_freshness=false, $freshness_threshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false,
    $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false,
    $check_interval=false, $retry_interval=false, $notification_period=false, $notification_options=false, $max_check_attempts=false, $check_command=false,
    $arguments=false, $register=false, $nrpe=false, $proxy=false, $customer_notify=true, $preventproxyoverride=false) {
  $contacts = $register ? {
    0       => "devnull",
    default => false,
  }
  $temp_use = $use ? {
    false          => $passive ? {
      true  => "passive_service",
      false => $ha ? {
        true  => "ha_service",
        false => $sms ? {
          false => "mail_service",
          true  => $warnsms ? {
            true  => "warnsms_service",
            false => "critsms_service",
          },
        },
      },
    },
    " "            => false,
    default        => $use,
  }
  $real_use = $temp_use ? {
    false   => false,
    default => $customer_notify ? {
      true  => "${temp_use}_${::environment}",
      false => $temp_use,
    },
  }
  $real_name = $conf_dir ? {
    /.*generic.*/ => $name,
    default       => "${name}_${host_name}",
  }
  if $check_interval and (!$notification_interval or $check_interval > $notification_interval) {
    $real_notification_interval = $check_interval
  } else {
    $real_notification_interval = $notification_interval
  }

  if $ha {
    Gen_icinga::Host <| title == $host_name |> {
      hostgroups => "ha_hosts",
    }
  }

  if $nrpe and $register != 0 and $service_description != "NRPE port" {
    gen_icinga::servicedependency { "nrpe_dependency_${real_name}_nrpe_port":
      ensure                        => $ensure,
      dependent_host_name           => $host_name,
      conf_dir                      => $conf_dir,
      dependent_service_description => $service_description,
      host_name                     => $host_name,
      service_description           => "NRPE port",
      execution_failure_criteria    => "c",
      notification_failure_criteria => "c";
    }
  } else {
    gen_icinga::servicedependency { "nrpe_dependency_${real_name}_nrpe_port":
      ensure                        => absent,
      dependent_host_name           => $host_name,
      conf_dir                      => $conf_dir,
      dependent_service_description => $service_description,
      host_name                     => $host_name,
      service_description           => "NRPE port",
      execution_failure_criteria    => "c",
      notification_failure_criteria => "c";
    }
  }

  gen_icinga::service { $real_name:
    conf_dir                     => $conf_dir,
    use                          => $real_use,
    servicegroups                => $servicegroups,
    service_description          => $service_description,
    check_command                => $check_command,
    host_name                    => $register ? {
      0       => undef,
      default => $host_name,
    },
    initial_state                => $initial_state,
    active_checks_enabled        => $active_checks_enabled,
    passive_checks_enabled       => $passive_checks_enabled,
    obsess_over_service          => $obsess_over_service,
    check_freshness              => $check_freshness,
    freshness_threshold          => $freshness_threshold,
    notifications_enabled        => $notifications_enabled,
    event_handler_enabled        => $event_handler_enabled,
    flap_detection_enabled       => $flap_detection_enabled,
    process_perf_data            => $process_perf_data,
    retain_status_information    => $retain_status_information,
    retain_nonstatus_information => $retain_nonstatus_information,
    notification_interval        => $real_notification_interval,
    is_volatile                  => $is_volatile,
    check_period                 => $check_period,
    check_interval               => $check_interval,
    retry_interval               => $retry_interval,
    notification_period          => $notification_period,
    notification_options         => $notification_options,
    contact_groups               => false,
    contacts                     => $contacts,
    max_check_attempts           => $max_check_attempts,
    arguments                    => $arguments,
    register                     => $register,
    ensure                       => $ensure,
    proxy                        => $proxy;
  }
}

# Define: kbp_icinga::host
#
# Parameters:
#  Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  gen_puppet
define kbp_icinga::host($conf_dir="${::environment}/${name}",$sms=true,$use=false,$hostgroups=false,$parents=false,$address=$external_ipaddress,$ensure=present,
    $initial_state=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false,
    $retain_nonstatus_information=false, $check_command="check_ping", $check_interval=false, $notification_period=false, $notification_interval=false, $max_check_attempts=false,
    $register=1, $proxy=false, $preventproxyoverride=false) {
  $contacts = $register ? {
    0       => "devnull",
    default => false,
  }
  $real_use = $use ? {
    false   => $sms ? {
      true  => "wh_host_${::environment}",
      false => "mail_host_${::environment}",
    },
    " "     => false,
    default => $use,
  }

  gen_icinga::host { $name:
    ensure                       => $ensure,
    conf_dir                     => $conf_dir,
    use                          => $real_use,
    hostgroups                   => $hostgroups,
    parents                      => $parents,
    address                      => $address,
    initial_state                => $initial_state,
    notifications_enabled        => $notifications_enabled,
    event_handler_enabled        => $event_handler_enabled,
    flap_detection_enabled       => $flap_detection_enabled,
    process_perf_data            => $process_perf_data,
    retain_status_information    => $retain_status_information,
    retain_nonstatus_information => $retain_nonstatus_information,
    check_command                => $check_command,
    check_interval               => $check_interval,
    notification_period          => $notification_period,
    notification_interval        => $notification_interval,
    contact_groups               => false,
    contacts                     => $contacts,
    max_check_attempts           => $max_check_attempts,
    register                     => $register,
    proxy                        => $proxy;
  }
}

define kbp_icinga::servercommand($conf_dir="generic", $command_name=false, $host_argument='-H $HOSTADDRESS$', $arguments=false, $nrpe=false, $time_out=30) {
  gen_icinga::servercommand { $name:
    conf_dir      => $conf_dir,
    command_name  => $command_name,
    host_argument => $host_argument,
    arguments     => $arguments,
    nrpe          => $nrpe,
    time_out      => $time_out;
  }
}

# Define: kbp_icinga::ipsec
#
# Actions:
#  Monitor an ipsec tunnel with ping check via NRPE
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::ipsec ($monitoring_remote_ip) {
  kbp_icinga::service { "ipsec_peer_${name}":
    service_description => "IPSEC peer ${name}",
    check_command       => "check_ping_nrpe",
    arguments           => [$monitoring_remote_ip],
    nrpe                => true;
  }
}

# Class: kbp_icinga::pacemaker
#
# Actions:
#  Set monitoring for pacemaker
#
# Depends:
#  gen_puppet
class kbp_icinga::pacemaker {
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

# Define: kbp_icinga::drbd
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::drbd {
  include gen_base::python-argparse

  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_icinga::service { "drbd_mount_${sanitized_name}":
    service_description => "DRBD mount ${name}",
    check_command       => "check_drbd_mount",
    arguments           => ["${name}/.monitoring","DRBD_mount_ok"],
    nrpe                => true;
  }

  kbp_icinga::service { "check_drbd":
    service_description => "DRBD",
    check_command       => "check_drbd",
    nrpe                => true,
    warnsms             => false;
  }
}

# Define: kbp_icinga::nfs::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::nfs::client {
  include gen_base::python-argparse

  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_icinga::service { "nfs_mount_${sanitized_name}":
    service_description => "NFS mount ${name}",
    check_command       => "check_nfs_client",
    arguments           => ["${name}/.monitoring","NFS_mount_ok"],
    nrpe                => true;
  }
}

# Define: kbp_icinga::sslcert
#
# Parameters:
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
define kbp_icinga::sslcert($path="/etc/ssl/certs/${name}.pem") {
  if !defined(Gen_sudo::Rule["check_sslcert sudo rules"]) {
    gen_sudo::rule { "check_sslcert sudo rules":
      entity            => "nagios",
      as_user           => "root",
      password_required => false,
      command           => "/usr/lib/nagios/plugins/check_sslcert";
    }
  }

  kbp_icinga::service { "ssl_cert_${name}":
    service_description => "SSL certificate in ${path}",
    check_command       => "check_sslcert",
    arguments           => $path,
    nrpe                => true;
  }
}

# Class: kbp_icinga::rabbitmqctl
#
# Parameters:
#  namespace
#    Namespace of the queues to check
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::rabbitmqctl($namespace) {
  kbp_icinga::service { "rabbitmqctl_${name}":
    service_description => "Stale messages in RabbitMQ in ${namespace}",
    check_command       => "check_rabbitmqctl",
    arguments           => $namespace,
    nrpe                => true,
    sms                 => false;
  }
}

# Define: kbp_icinga::virtualhost
#
# Parameters:
#  conf_dir
#    Undocumented
#  environment
#    Undocumented
#  parents
#    Undocumented
#  hostgroups
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
define kbp_icinga::virtualhost($address, $ensure=present, $conf_dir=$::environment, $parents=false, $hostgroups=false, $sms=true, $notification_period=false, $proxy=false, $preventproxyoverride=false) {
  $confdir = "${conf_dir}/${name}"

  gen_icinga::configdir { $confdir:
    ensure => $ensure;
  }

  kbp_icinga::host { $name:
    ensure                => $ensure,
    conf_dir              => $confdir,
    address               => $address,
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
    },
    proxy                 => $proxy,
    preventproxyoverride  => $preventproxyoverride;
  }
}

# Define: kbp_icinga::haproxy
#
# Parameters:
#  ha
#    Undocumented
#  url
#    Undocumented
#  response
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
define kbp_icinga::haproxy($address, $ha=false, $url=false, $port=false, $host_name=false, $response=false,
    $statuscode="200", $max_check_attempts=false, $ssl=false, $preventproxyoverride=false) {
  kbp_icinga::site { "${name}_80":
    address              => $address,
    port                 => $port,
    path                 => $url,
    max_check_attempts   => $max_check_attempts,
    statuscode           => $ssl ? {
      false => $statuscode,
      true  => "301",
    },
    host_name            => $host_name ? {
      false   => $name,
      default => $host_name,
    },
    vhost                => false,
    preventproxyoverride => $preventproxyoverride;
  }

  if $ssl {
    kbp_icinga::site { "${name}_443":
      address              => $address,
      ssl                  => true,
      port                 => $port,
      path                 => $url,
      max_check_attempts   => $max_check_attempts,
      statuscode           => $statuscode,
      host_name            => $ssl ? {
        false   => $name,
        default => $host_name,
      },
      vhost                => false,
      preventproxyoverride => $preventproxyoverride;
    }
  }
}

# Define: kbp_icinga::java
#
# Parameters:
#  sms
#    Undocumented
#  servicegroups
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::java($servicegroups=false, $sms=true) {
  kbp_icinga::service { "java_heap_usage_${name}":
    service_description => "Java heap usage ${name}",
    check_command       => "check_java_heap_usage",
    max_check_attempts  => 12,
    arguments           => $name,
    servicegroups       => $servicegroups ? {
      false   => undef,
      default => $servicegroups,
    },
    nrpe                => true,
    sms                 => $sms;
  }
}

# Define: kbp_icinga::site
#
# Parameters:
#  conf_dir
#    Undocumented
#  parents
#    Undocumented
#  fqdn
#    Undocumented
#  auth
#    Undocumented
#  address
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
define kbp_icinga::site($address=false, $address6=false, $conf_dir=false, $parents=$::fqdn, $service_description=false, $auth=false,
      $max_check_attempts=false, $port=false, $path=false, $response=false, $statuscode=false, $vhost=true,
      $ssl=false, $host_name=false, $preventproxyoverride=false, $check_interval=false) {
  $real_name = $host_name ? {
    false   => $name,
    default => $host_name,
  }
  $real_statuscode = $statuscode ? {
    false   => $auth ? {
      true  => "401,403",
      false => "200",
    },
    default => $statuscode,
  }

  if ! $vhost {
    $confdir = $conf_dir ? {
      false   => "${::environment}/${real_name}",
      default => "${conf_dir}/${real_name}",
    }

    if !defined(Gen_icinga::Configdir[$confdir]) {
      gen_icinga::configdir { $confdir:; }
    }

    if !defined(Kbp_icinga::Host[$real_name]) {
      kbp_icinga::host { $real_name:
        conf_dir => $confdir,
        address  => $address,
        parents  => $parents;
      }
    }
  }

  if $port and $port != 80 {
    if $path {
      if $response {
        $check_command = "check_http_vhost_port_url_response"
        $arguments     = [$real_name,$port,$path,$response,$real_statuscode]
      } else {
        $check_command = "check_http_vhost_port_url"
        $arguments     = [$real_name,$port,$path,$real_statuscode]
      }
    } else {
      $check_command = "check_http_vhost_port"
      $arguments     = [$real_name,$port,$real_statuscode]
    }
  } elsif $path {
    if $response {
      $check_command = "check_http_vhost_url_response"
      $arguments     = [$real_name,$path,$response,$real_statuscode]
    } elsif $ssl {
      $check_command = "check_http_vhost_url_ssl"
      $arguments     = [$real_name,$path,$real_statuscode]
    } else {
      $check_command = "check_http_vhost_url"
      $arguments     = [$real_name,$path,$real_statuscode]
    }
  } elsif $response {
    $check_command = "check_http_vhost_response"
    $arguments     = [$real_name,$response,$real_statuscode]
  } elsif $ssl {
    $check_command = "check_http_vhost_ssl"
    $arguments     = [$real_name,$real_statuscode]
  } else {
    $check_command = "check_http_vhost"
    $arguments     = [$real_name,$real_statuscode]
  }

  if $address == false or $address == "*" {
    $real_check_command = $check_command
    $real_arguments = $arguments
  } else {
    $real_check_command = "${check_command}_address"
    $real_arguments = split(inline_template("<%= ([address] + arguments).join('|') %>"),'[|]')
  }

  kbp_icinga::service { "vhost_${name}":
    conf_dir             => $confdir,
    service_description  => $service_description ? {
      false   => "Vhost ${real_name}",
      default => $service_description,
    },
    host_name            => $vhost ? {
      true  => $fqdn,
      false => $real_name,
    },
    check_command        => $real_check_command,
    max_check_attempts   => $max_check_attempts,
    arguments            => $real_arguments,
    preventproxyoverride => $preventproxyoverride,
    check_interval       => $check_interval;
  }
}

# Define: kbp_icinga::sslsite
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::sslsite {
  kbp_icinga::service { "ssl_site_${name}":
    service_description => "SSL validity ${name}",
    check_command       => "check_ssl_cert",
    arguments           => $name,
    warnsms             => false;
  }
}

# Define: kbp_icinga::raidcontroller
#
# Parameters:
#  driver
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::raidcontroller($driver) {
  kbp_icinga::service { "${name}":
    service_description => "Raid ${name} ${driver}",
    check_command       => "check_${driver}",
    nrpe                => true,
    warnsms             => false;
  }
}

# Define: kbp_icinga::http
#
# Parameters:
#  fqdn
#    Undocumented
#  auth
#    Undocumented
#  customfqdn
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::http($customfqdn=$::fqdn, $auth=false, $proxy=false, $preventproxyoverride=false) {
  kbp_icinga::service { "http_${customfqdn}":
    conf_dir             => "${::environment}/${customfqdn}",
    service_description  => "HTTP",
    host_name            => $customfqdn,
    check_command        => "check_http",
    arguments            => "200,301,302,401,403",
    proxy                => $proxy,
    preventproxyoverride => $preventproxyoverride;
  }
}

# Define: kbp_icinga::proc_status
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::proc_status {
  kbp_icinga::service { "proc_status_${name}":
    service_description => "Process status for ${name}",
    check_command       => "check_proc_status",
    arguments           => $name,
    nrpe                => true;
  }
}

# Define: kbp_icinga::glassfish
#
# Parameters:
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
define kbp_icinga::glassfish($webport, $statuspath=false) {
  $realpath = $statuspath ? {
    false   => "/${name}/status.jsp",
    default => "${statuspath}/status.jsp",
  }

  kbp_icinga::site { $name:
    service_description => "Glassfish ${name} status",
    host_name           => $fqdn,
    port                => $webport,
    path                => $realpath,
    response            => "RUNNING";
  }
}

# Define: kbp_icinga::mbean_value
#
# Parameters:
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
define kbp_icinga::mbean_value($jmxport, $objectname, $attributename, $expectedvalue, $attributekey=false, $customname=false) {
  kbp_icinga::service { "mbean_${name}":
    service_description => $customname ? {
      false   => "Mbean ${name} status",
      default => $customname,
    },
    check_command       => "check_mbean_value",
    arguments           => $attributekey ? {
      false   => [$jmxport,$objectname,$attributename,$expectedvalue],
      default => [$jmxport,$objectname,$attributename,$expectedvalue,$attributekey],
    };
  }

  if $attributekey {
    file { "/etc/nagios/nrpe.d/mbean_${jmxport}_${attributename}_${expectedvalue}_${attributekey}.conf":
      content => template("kbp_icinga/mbean_value.conf");
    }
  } else {
    file { "/etc/nagios/nrpe.d/mbean_${jmxport}_${attributename}_${expectedvalue}.conf":
      content => template("kbp_icinga/mbean_value.conf");
    }
  }
}

# Define: kbp_icinga::dnszone
#
# Parameters:
#  sms
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
define kbp_icinga::dnszone($master, $sms=true) {
  include gen_base::python-argparse
  include gen_base::python-ipaddr
  include gen_base::python-dnspython

  kbp_icinga::service { "dnszone_${name}":
    service_description => "DNS zone ${name} from ${master}",
    check_command       => "check_dnszone",
    arguments           => [$name,$master],
    nrpe                => true,
    check_interval      => 60,
    retry_interval      => 60,
    sms                 => $sms;
  }
}
