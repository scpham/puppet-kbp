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
    "check_activemq":
      command   => "check_procs",
      arguments => "-c 1: -C java -a activemq";
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
    "check_doublemount":;
    "check_mount":
      sudo      => true,
      command   => "check_mount",
      arguments => '$ARG1$';
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
    'check_haproxy_errors':
      sudo      => true,
      arguments => '-i $ARG1$ -w $ARG2$ -c $ARG3$';
    "check_heartbeat":;
    'check_http_port_url':
      command   => 'check_http',
      arguments => ['-I 127.0.0.1 -p $ARG1$ -u $ARG2$ -e $ARG3$ -t 20'];
    "check_icinga_config":
      sudo      => true,
      arguments => '$ARG1$';
    "check_java_heap_usage":
      command   => "check_javaheapusage",
      arguments => '/etc/munin/plugins/jmx_$ARG1$_java_process_memory 96 93';
    "check_java_heap_usage_auth":
      command   => "check_javaheapusage_auth",
      arguments => '$ARG1$ 96 93 $ARG2$ $ARG3$';
    "check_java_heap_usage_auth_autostart":
      command   => "check_javaheapusage_auth_autostart",
      arguments => '$ARG1$ $ARG2$ 96 93 $ARG3$ $ARG4$';
    "check_ksplice":
      command   => "check_uptrack_local",
      arguments => "-w i -c o";
    "check_loadtrend":
      arguments => "-m 1.5 -c 5 -w 2.5";
    "check_local_smtp":
      command   => "check_smtp",
      arguments => "-H 127.0.0.1";
    "check_lsimpt":
      sudo      => true;
    "check_mbean_value":
      arguments => '$ARG1$ $ARG2$ $ARG3$ $ARG4$';
    "check_mcollective":
      command   => "check_procs",
      arguments => "-c 1:1 -C ruby -a /usr/sbin/mcollectived";
    "check_megaraid_sas":
      sudo      => true;
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
    "check_nomonitoring":
      sudo      => true,
      command   => "check_file",
      arguments => '-f $ARG1$ -n';
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
    "check_pgsql":
      sudo      => "postgres";
    "check_proc_status":
      sudo      => true,
      arguments => '$ARG1$';
    "check_puppet_dontrun":
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
    "check_tomcat":
      arguments => '-p 8080 -l monitoring -a $ARG1$ -n .';
    "check_tomcat_application":
      arguments => '-u monitoring -p $ARG1$ -a $ARG2$';
    "check_unbound":
      command   => "check_procs",
      arguments => "-c 1:1 -C unbound";
    "check_zombie_processes":
      command   => "check_procs",
      arguments => "-w 5 -c 10 -s Z";
  }

  kbp_icinga::configdir { "${::environment}/${fqdn}":
    override_nomonitoring => true;
  }

  kbp_icinga::host { $fqdn:
    parents               => $parent,
    override_nomonitoring => true;
  }

  if $is_virtual == "true" {
    kbp_icinga::service { "memory":
      service_description => "Memory usage",
      check_command       => "check_memory",
      max_check_attempts  => 30,
      nrpe                => true,
      warnsms             => false;
    }
  }

  kbp_icinga::service {
    "puppet_nomonitoring":
      service_description   => "Nomonitoring exists",
      check_command         => "check_nomonitoring",
      arguments             => ["/etc/puppet/nomonitoring"],
      nrpe                  => true,
      sms                   => false,
      customer_notify       => false,
      override_nomonitoring => true;
    "nrpe":
      service_description   => "NRPE port",
      check_command         => "return-ok_nrpe",
      nrpe                  => true,
      customer_notify       => false,
      override_nomonitoring => true;
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
    "smtp_gateway":
      service_description => "SMTP gateway",
      check_command       => "check_local_smtp",
      check_interval      => 300,
      nrpe                => true,
      sms                 => false,
      customer_notify     => false;
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

  kbp_icinga::servicedependency { "puppet_dependency_freshness_dontrun":
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

class kbp_icinga::server($dbpassword, $dbhost="localhost", $ssl=true, $authorized_users=false) {
  include gen_icinga::server
  include kbp_nsca::server
  include kbp_munin::client::icinga
  include gen_php5::xsl

  # icinga.cfg options
  $object_cache_file                        = '/var/cache/icinga/objects.cache'
  $status_file                              = '/var/cache/icinga/status.dat'
  $status_update_interval                   = 2
  $check_external_commands                  = 1
  $log_rotation_method                      = 'n'
  $use_syslog                               = 0
  $check_result_reaper_frequency            = 1
  $check_result_path                        = '/var/cache/icinga/checkresults'
  $soft_state_dependencies                  = 1
  $interval_length                          = 1
  $enable_event_handlers                    = 0
  $allow_empty_hostgroup_assignment         = 1
  $check_service_freshness                  = 0
  $use_large_installation_tweaks            = 1
  $enable_environment_macros                = 0
  $debug_verbosity                          = 1
  $temp_path                                = '/var/cache/icinga/tmp'
  $log_file                                 = '/var/cache/icinga/icinga.log'
  # cgi.cfg options
  $url_html_path                            = '/'
  $url_stylesheets_path                     = '/stylesheets'
  $show_context_help                        = 1
  $authorized_for_system_information        = $authorized_users
  $authorized_for_configuration_information = $authorized_users
  $authorized_for_full_command_resolution   = $authorized_users
  $authorized_for_system_commands           = $authorized_users
  $authorized_for_all_services              = $authorized_users
  $authorized_for_all_hosts                 = $authorized_users
  $authorized_for_all_service_commands      = $authorized_users
  $authorized_for_all_host_commands         = $authorized_users
  $show_partial_hostgroups                  = 1
  $refresh_rate                             = 20
  $default_downtime_duration                = 3600
  $display_status_totals                    = 1
  $suppress_maintenance_downtime            = 1

  package { ["icinga-web", 'icinga-mobile']:;}

  gen_logrotate::rotate { "icinga":
    logs => "/var/cache/icinga/icinga.log",
    options => ["daily", "compress","rotate 21","missingok"];
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
    "/etc/icinga-web/conf.d/databases.xml":
      content => template("kbp_icinga/icinga-web/databases.xml"),
      owner   => "www-data",
      mode    => 600,
      require => Package["icinga-web"],
      notify  => Exec["clearcache_icinga-web"];
    "/etc/icinga-web/conf.d/auth.xml":
      content => template("kbp_icinga/icinga-web/auth.xml"),
      require => Package["icinga-web"],
      notify  => Exec["clearcache_icinga-web"];
    "/etc/icinga-web/conf.d/translation.xml":
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
    '/etc/icinga/build_icinga_config':
      content => template('kbp_icinga/server/build_icinga_config'),
      mode    => 750;
    '/etc/icinga/update_icinga_config':
      content => template('kbp_icinga/server/update_icinga_config'),
      mode    => 750;
    '/var/log/icinga':
      ensure  => link,
      force   => true,
      target  => '/var/cache/icinga/';
    '/var/cache/icinga/tmp':
      ensure  => directory,
      owner   => 'nagios';
  }

  exec { 'build_icinga_config':
    onlyif  => "/etc/icinga/build_icinga_config -s ${dbhost} -p ${dbpassword} && /usr/sbin/icinga -v /etc/icinga/tmp_icinga.cfg",
    command => '/etc/icinga/update_icinga_config',
    require => File['/etc/icinga/build_icinga_config','/etc/icinga/update_icinga_config'],
    notify  => Exec['reload-icinga'];
  }

  exec { "clearcache_icinga-web":
    command     => "/usr/lib/icinga-web/bin/clearcache.sh",
    refreshonly => true;
  }

  @@mysql::server::db { ["icinga for ${fqdn}", "icinga_web for ${fqdn}"]:
    tag => "mysql_kumina";
  }

  @@mysql::server::grant {
    "icinga on icinga for ${fqdn}":
      user        => "icinga",
      db          => "icinga",
      password    => $dbpassword,
      hostname    => "%",
      tag         => "mysql_kumina";
    "icinga on icinga_web for ${fqdn}":
      user        => "icinga",
      db          => "icinga_web",
      password    => $dbpassword,
      hostname    => "%",
      tag         => "mysql_kumina";
    "icinga on puppet for ${fqdn}":
      user        => 'icinga',
      db          => 'puppet',
      password    => $dbpassword,
      hostname    => $fqdn,
      permissions => 'SELECT',
      tag         => 'mysql_kumina';
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
    "Solr monitoring":
      saddr    => $source_ipaddress,
      proto    => "tcp",
      dport    => 8983,
      action   => "ACCEPT",
      exported => true,
      ferm_tag => "solr_monitoring";
  }

  Kbp_icinga::Servercommand <<| |>>

  kbp_icinga::servercommand {
    ["check_ssh","check_smtp"]:;
    ["check_asterisk","check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd",
     "check_pacemaker","check_mysql","check_mysql_connlimit","check_mysql_slave","check_loadtrend","check_heartbeat","check_ntpd","check_remote_ntp","check_coldfusion","check_dhcp",
     "check_arpwatch","check_3ware","check_adaptec","check_cassandra","check_swap","check_puppet_failures",'check_megaraid_sas',"check_nullmailer","check_passenger_queue","check_mcollective","check_backup_status",
     'check_unbound', 'check_activemq', 'check_lsimpt','check_doublemount']:
      nrpe          => true;
    "return-ok":
      command_name  => "check_dummy",
      host_argument => false,
      arguments     => "0";
    "return-ok_nrpe":
      command_name  => "check_dummy",
      nrpe          => true,
      arguments     => "0";
    "check_mount":
      command_name  => "check_mount",
      arguments     => ['$ARG1$'],
      nrpe          => true;
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
    'check_haproxy_errors':
      arguments     => ['$ARG1$', '$ARG2$', '$ARG3$'],
      nrpe          => true;
    "check_http":
      arguments     => ['-I $HOSTADDRESS$','-e $ARG1$','-t 20','-N'];
    "check_http_cert":
      command_name  => "check_http",
      host_argument => '-H $ARG1$',
      arguments     => ['-C 30,10', '-t 20'];
    "check_http_port_url":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-p $ARG1$','-u $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_port_url_nrpe":
      command_name  => "check_http_port_url",
      arguments     => ['$ARG1$','$ARG2$','$ARG3$'],
      nrpe          => true;
    "check_http_ssl":
      command_name  => "check_http",
      arguments     => ['--ssl=3', '-I $HOSTADDRESS$', '-e $ARG1$', '-t 20','-N'];
    "check_http_vhost":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-e $ARG2$','-t 20','-N'];
    "check_http_vhost_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_vhost_port":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-p $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_vhost_response":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-r $ARG2$','-e $ARG3$','-t 20'];
    "check_http_vhost_response_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-r $ARG3$','-e $ARG4$','-t 20'];
    "check_http_vhost_ssl":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['--ssl=3','-H $ARG1$','-e $ARG2$','-t 20','-N'];
    "check_http_vhost_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['--ssl=3','-H $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_vhost_url":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-u $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_vhost_url_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-u $ARG3$','-e $ARG4$','-t 20','-N'];
    "check_http_vhost_url_login_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['--ssl=3', '-H $ARG2$', '-u $ARG3$', '-a $ARG4$', '-e $ARG5$', '-t 20', '-N'];
    "check_http_vhost_url_login_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-u $ARG3$','-a $ARG4$', '-e $ARG5$', '-t 20', '-N'];
    "check_http_vhost_url_ssl":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['--ssl=3','-H $ARG1$','-u $ARG2$','-e $ARG3$','-t 20','-N'];
    "check_http_vhost_url_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['--ssl=3','-H $ARG2$','-u $ARG3$','-e $ARG4$','-t 20','-N'];
    "check_http_vhost_url_response":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['-H $ARG1$','-u $ARG2$','-r $ARG3$','-e $ARG4$','-t 20'];
    "check_http_vhost_url_response_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['-H $ARG2$','-u $ARG3$','-r $ARG4$','-e $ARG5$','-t 20'];
    "check_http_vhost_url_response_ssl":
      command_name  => "check_http",
      host_argument => '-I $HOSTADDRESS$',
      arguments     => ['--ssl=3', '-H $ARG1$', '-u $ARG2$', '-r $ARG3$', '-e $ARG4$', '-t 20'];
    "check_http_vhost_url_response_ssl_address":
      command_name  => "check_http",
      host_argument => '-I $ARG1$',
      arguments     => ['--ssl=3', '-H $ARG2$', '-u $ARG3$', '-r $ARG4$', '-e $ARG5$', '-t 20'];
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
    "check_nomonitoring":
      arguments     => ['$ARG1$'],
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
    "check_java_heap_usage_auth":
      arguments     => ['$ARG1$','$ARG2$','$ARG3$'],
      nrpe          => true;
    "check_java_heap_usage_auth_autostart":
      arguments     => ['$ARG1$','$ARG2$','$ARG3$','$ARG4$'],
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
    "check_pgsql":
      nrpe      => true;
    'check_tomcat':
      nrpe      => true,
      arguments => '$ARG1$';
    'check_tomcat_application':
      nrpe      => true,
      arguments => ['$ARG1$','$ARG2$'];
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
    '/etc/icinga/tmp_icinga.cfg':
      content => template('kbp_icinga/server/tmp_icinga.cfg'),
      require => Package['icinga'];
    "/etc/icinga/notify_commands.cfg":
      content => template("kbp_icinga/server/config/generic/notify_commands.cfg"),
      notify  => Exec["reload-icinga"];
  }

  kbp_icinga::icinga_config { ['/etc/icinga/icinga.cfg', '/etc/icinga/tmp_icinga.cfg']:; }

  setfacl { "Allow www-data to read the command file":
    dir          => "/var/lib/icinga/rw",
    acl          => "group:www-data:rw-",
    mask         => "rw-",
    make_default => true;
  }

  gen_icinga::configdir { "generic":; }

  kbp_icinga::service {
    "ha_service":
      conf_dir                     => "generic",
      use                          => " ",
      servicegroups                => "ha_services",
      initial_state                => "u",
      obsess_over_service          => 0,
      check_freshness              => 0,
      notifications_enabled        => 1,
      event_handler_enabled        => 0,
      retain_status_information    => 1,
      retain_nonstatus_information => 1,
      is_volatile                  => 0,
      notification_period          => "24x7",
      active_checks_enabled        => 1,
      passive_checks_enabled       => 0,
      flap_detection_enabled       => 1,
      process_perf_data            => 1,
      notification_interval        => 600,
      check_period                 => "24x7",
      check_interval               => 30,
      retry_interval               => 10,
      max_check_attempts           => 3,
      notification_options         => "w,u,c,r",
      register                     => 0;
    "critsms_service":
      conf_dir                     => "generic",
      use                          => "ha_service",
      servicegroups                => "wh_services_critsms",
      register                     => 0;
    "warnsms_service":
      conf_dir                     => "generic",
      use                          => "ha_service",
      servicegroups                => "wh_services_warnsms",
      register                     => 0;
    "mail_service":
      conf_dir                     => "generic",
      use                          => "ha_service",
      servicegroups                => "mail_services",
      register                     => 0;
    "passive_service":
      conf_dir                     => "generic",
      use                          => "ha_service",
      servicegroups                => "mail_services",
      active_checks_enabled        => 0,
      passive_checks_enabled       => 1,
      check_command                => "return-ok",
      register                     => 0;
  }

  kbp_icinga::host {
    "ha_host":
      conf_dir                     => "generic",
      use                          => " ",
      hostgroups                   => "ha_hosts",
      initial_state                => "u",
      notifications_enabled        => 1,
      event_handler_enabled        => 0,
      flap_detection_enabled       => 1,
      process_perf_data            => 1,
      retain_status_information    => 1,
      retain_nonstatus_information => 1,
      check_interval               => 20,
      retry_interval               => 20,
      notification_period          => "24x7",
      notification_interval        => 600,
      max_check_attempts           => 3,
      register                     => 0;
    "wh_host":
      conf_dir   => "generic",
      use        => "ha_host",
      hostgroups => "wh_hosts",
      register   => 0;
    "mail_host":
      conf_dir   => "generic",
      use        => "ha_host",
      hostgroups => "mail_hosts",
      register   => 0;
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

  kbp_icinga::contact {
    "devnull":
      conf_dir                      => "generic",
      c_alias                       => "No notify contact",
      contactgroups                 => "devnull",
      host_notifications_enabled    => 0,
      service_notifications_enabled => 0,
      contact_data                  => false;
    "generic_email":
      conf_dir                      => "generic",
      c_alias                       => "Generic email",
      contactgroups                 => "generic_email",
      contact_data                  => false;
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
    mailto  => "root",
    minute  => "*/5",
    command => "/usr/bin/icinga-check-alive";
  }

  @@kbp_munin::alert_export { "icinga on ${fqdn}":
    command => "/usr/sbin/send_nsca -H ${fqdn} -c /etc/send_nsca.cfg";
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

  kbp_icinga::contact { "${::environment}":
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
      use                          => 'ha_service',
      servicegroups                => "ha_services,${::environment}_services",
      register                     => "0";
    "critsms_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "critsms_service",
      servicegroups                => "wh_services_critsms,${::environment}_services",
      register                     => "0";
    "warnsms_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "warnsms_service",
      servicegroups                => "wh_services_warnsms,${::environment}_services",
      register                     => "0";
    "mail_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "mail_service",
      servicegroups                => "mail_services,${::environment}_services",
      register                     => "0";
    "passive_service_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "passive_service",
      servicegroups                => "mail_services,${::environment}_services",
      register                     => "0";
  }

  kbp_icinga::host {
    "ha_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => 'ha_host',
      hostgroups                   => "ha_hosts,${::environment}_hosts",
      register                     => "0";
    "wh_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "wh_host",
      hostgroups                   => "wh_hosts,${::environment}_hosts",
      register                     => "0";
    "mail_host_${::environment}":
      conf_dir                     => "${::environment}/generic",
      use                          => "mail_host",
      hostgroups                   => "mail_hosts,${::environment}_hosts",
      register                     => "0";
  }
}

# Class: kbp_icinga:activemq
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::activemq {
  kbp_icinga::service { "activemq":
    service_description => "ActiveMQ status",
    check_command       => "check_activemq",
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

# Class: kbp_icinga::nfs::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_icinga::nfs::server ($failover_ip=false, $failover_name="nfs.${domain}", $ip_proxy=false) {
  if $failover_ip {
    $conf_dir = "${environment}/${failover_name}"

    if !defined(Gen_icinga::Configdir[$conf_dir]) {
      gen_icinga::configdir { $conf_dir:
        ensure => $ensure;
      }
    }

    if !defined(Kbp_icinga::Host[$failover_name]) {
      kbp_icinga::host { $failover_name:
        conf_dir => $conf_dir,
        address  => $failover_ip,
        proxy    => $ip_proxy;
      }
    }
  }

  kbp_icinga::service { "nfs_daemon":
    conf_dir            => $conf_dir,
    service_description => "NFS daemon",
    host_name           => $failover_ip ? {
      false   => $fqdn,
      default => $failover_name,
    },
    check_command       => "check_nfs_server",
    proxy               => $ip_proxy;
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

define kbp_icinga::configdir($override_nomonitoring=false) {
  if $::monitoring == 'true' or ($override_nomonitoring and $::monitoring != 'force_off') {
    gen_icinga::configdir { $name:; }
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
define kbp_icinga::service($ensure="present", $service_description=false, $use=false, $servicegroups=false, $passive=false, $ha=false, $sms=true, $warnsms=true, $conf_dir="${environment}/${fqdn}", $host_name=$fqdn,
    $initial_state=false, $active_checks_enabled=false, $passive_checks_enabled=false, $obsess_over_service=false, $check_freshness=false, $freshness_threshold=false, $notifications_enabled=false, $event_handler_enabled=false,
    $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false, $check_interval=false,
    $retry_interval=false, $notification_period=false, $notification_options=false, $max_check_attempts=false, $check_command=false, $arguments=false, $register=false, $nrpe=false, $proxy=false, $customer_notify=true,
    $preventproxyoverride=false, $override_nomonitoring=false, $address=false) {
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
    default => $register ? {
      0       => $temp_use,
      default => $customer_notify ? {
        true  => "${temp_use}_${::environment}",
        false => $temp_use,
      },
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
  if ! $service_description and $register > 0 {
    fail("Missing parameter service_description.")
  }
  $full_check_command = $check_command ? {
    false   => false,
    default => $proxy ? {
      false   => $arguments ? {
        false   => $check_command,
        default => inline_template('<%= check_command + "!" + [arguments].flatten().join("!") %>'),
      },
      default => $arguments ? {
        false   => "proxy_${check_command}",
        default => inline_template('<%= "proxy_" + check_command + "!" + [arguments].flatten().join("!") %>'),
      },
    },
  }

  if $ha {
    Kbp_icinga::Host <| title == $host_name |> {
      hostgroups => "ha_hosts",
    }
    Gen_icinga::Host <| title == $host_name |> {
      hostgroups => "ha_hosts",
    }
  }

  if $::monitoring == 'true' or ($override_nomonitoring and $::monitoring != 'force_off') {
    if $ensure == 'present' and $nrpe and $register != 0 and $service_description != "NRPE port" {
      kbp_icinga::servicedependency { "nrpe_dependency_${real_name}_nrpe_port":
        dependent_host_name           => $host_name,
        conf_dir                      => $conf_dir,
        dependent_service_description => $service_description,
        host_name                     => $host_name,
        address                       => $address,
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
      check_command                => $full_check_command,
      base_check_command           => $check_command,
      host_name                    => $register ? {
        0       => undef,
        default => $host_name,
      },
      address                      => $address,
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
}

define kbp_icinga::servicedependency($ensure="present", $dependent_service_description, $host_name=$fqdn, $address=false, $service_description, $conf_dir="${environment}/${fqdn}", $dependent_host_name=$fqdn,
    $execution_failure_criteria=false, $notification_failure_criteria="o") {
  if $::monitoring == 'true' or ($::override_nomonitoring and $::monitoring != 'force_off') {
    gen_icinga::servicedependency { $name:
      ensure                        => $ensure,
      dependent_service_description => $dependent_service_description,
      host_name                     => $host_name,
      address                       => $address,
      service_description           => $service_description,
      conf_dir                      => $conf_dir,
      dependent_host_name           => $dependent_host_name,
      execution_failure_criteria    => $execution_failure_criteria,
      notification_failure_criteria => $notification_failure_criteria;
    }
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
    $register=1, $proxy=false, $preventproxyoverride=false, $retry_interval=false, $override_nomonitoring=false) {
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
  $full_check_command = $proxy ? {
    false   => $check_command,
    default => "proxy_${check_command}",
  }

  if $monitoring == 'true' or ($override_nomonitoring and $::monitoring != 'force_off') {
    gen_icinga::host { $name:
      ensure                       => $ensure,
      conf_dir                     => $conf_dir,
      use                          => $real_use,
      hostgroups                   => $hostgroups,
      parents                      => $parents,
      address                      => $register ? {
        0       => undef,
        default => $address,
      },
      initial_state                => $initial_state,
      notifications_enabled        => $notifications_enabled,
      event_handler_enabled        => $event_handler_enabled,
      flap_detection_enabled       => $flap_detection_enabled,
      process_perf_data            => $process_perf_data,
      retain_status_information    => $retain_status_information,
      retain_nonstatus_information => $retain_nonstatus_information,
      check_command                => $full_check_command,
      base_check_command           => $check_command,
      check_interval               => $check_interval,
      retry_interval               => $retry_interval,
      notification_period          => $notification_period,
      notification_interval        => $notification_interval,
      contact_groups               => false,
      contacts                     => $contacts,
      max_check_attempts           => $max_check_attempts,
      register                     => $register,
      proxy                        => $proxy;
    }
  }
}

define kbp_icinga::servercommand($conf_dir="generic", $command_name=$name, $host_argument='-H $HOSTADDRESS$', $arguments=false, $nrpe=false, $time_out=30) {
  $temp_command_line = $nrpe ? {
    true  => $host_argument ? {
      false   => "/usr/lib/nagios/plugins/check_nrpe -u -t ${time_out} -c ${command_name}",
      default => "/usr/lib/nagios/plugins/check_nrpe -u -t ${time_out} ${host_argument} -c ${command_name}",
    },
    false => $host_argument ? {
      false   => "/usr/lib/nagios/plugins/${command_name}",
      default => "/usr/lib/nagios/plugins/${command_name} ${host_argument}",
    },
  }
  $command_line = $arguments ? {
    false   => $temp_command_line,
    default => $nrpe ? {
      true  => inline_template('<%= temp_command_line + " -a " + [arguments].flatten().join(" ") %>'),
      false => inline_template('<%= temp_command_line + " " + [arguments].flatten().join(" ") %>'),
    },
  }
  $temp_proxy_command_line = $arguments ? {
    false   => $temp_command_line,
    default => $nrpe ? {
      true  => inline_template('<%= temp_command_line + " -a " + [arguments].flatten().join(" ") %>'),
      false => inline_template('<%= temp_command_line + " " + [arguments].flatten().join(" ") %>'),
    },
  }
  $proxy = $command_name ? {
    'check_ping' => '$_HOSTPROXY$',
    default      => '$_SERVICEPROXY$',
  }
  $proxy_command_line = "/usr/lib/nagios/plugins/check_nrpe -u -t ${time_out} -H ${proxy} -c runcommand -a '${temp_proxy_command_line}'"

  gen_icinga::servercommand {
    $name:
      conf_dir      => $conf_dir,
      command_name  => $command_name,
      command_line  => $command_line,
      host_argument => $host_argument,
      arguments     => $arguments,
      nrpe          => $nrpe,
      time_out      => $time_out;
    "proxy_${name}":
      conf_dir      => $conf_dir,
      command_name  => $command_name,
      command_line  => $proxy_command_line,
      host_argument => $host_argument,
      arguments     => $arguments,
      nrpe          => $nrpe,
      time_out      => $time_out,
      proxy         => true;
  }
}

# Define: kbp_icinga::icinga_config
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::icinga_config {
  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_icinga::service { "icinga_config_${sanitized_name}":
    service_description => "Icinga configuration ${name}",
    check_command       => "check_icinga_config",
    arguments           => $name,
    check_interval      => 900,
    nrpe                => true,
    sms                 => false;
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

# Define: kbp_icinga::cifs::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_icinga::mount {
  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_icinga::service { "mount_${sanitized_name}":
    service_description => "Mountpoint ${name}",
    check_command       => "check_mount",
    arguments           => [$name],
    nrpe                => true;
  }
}

# Class: kbp_icinga::doublemount
#
# Actions:
#  Checks wether mountpoints are used more than once
#
# Depends:
#  kbp_icinga
#
class kbp_icinga::doublemount {
  kbp_icinga::service { "doublemount":
    service_description => "Double mounts",
    check_command       => "check_doublemount",
    check_interval      => 3600,
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
    nrpe                => true,
    warnsms             => false;
  }
}

# Class: kbp_icinga::unbound
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
class kbp_icinga::unbound {
  kbp_icinga::service { "unbound":
    service_description => "Unbound daemon",
    check_command       => "check_unbound",
    sms                 => true,
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
define kbp_icinga::java($servicegroups=false, $sms=true, $username=false, $password=false, $autostart_path=false) {
  if $autostart_path {
    $autostart="_autostart"
  } else {
    $autostart=""
  }

  if $username {
    $auth="_auth"
  } else {
    $auth=""
  }

  kbp_icinga::service { "java_heap_usage_${name}":
    service_description => "Java heap usage ${name}",
    check_command       => "check_java_heap_usage${auth}${autostart}",
    max_check_attempts  => 12,
    arguments           => $username ? {
      false   => $name,
      default => $autostart_path ? {
        false   => [$name, $username, $password],
        default => [$name, $autostart_path, $username, $password],
      },
    },
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
      $max_check_attempts=false, $port=false, $path=false, $response=false, $statuscode=false, $vhost=true, $ha=false,
      $ssl=false, $host_name=false, $preventproxyoverride=false, $check_interval=false, $credentials=false, $proxy=false) {
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
      gen_icinga::configdir { $confdir:
        host_name => $real_name,
        address   => $address;
      }
    }

    if !defined(Kbp_icinga::Host[$real_name]) {
      kbp_icinga::host { $real_name:
        conf_dir             => $confdir,
        address              => $address,
        parents              => $parents,
        proxy                => $proxy,
        preventproxyoverride => false;
      }
    }
  }

  $check_command_vhost = 'check_http_vhost'
  $arguments_vhost     = $real_name
  if $port and $port != 80 and (! $ssl or $port != 443) {
    $check_command_port = "${check_command_vhost}_port"
    $arguments_port     = "${arguments_vhost}|${port}"
  } else {
    $check_command_port = $check_command_vhost
    $arguments_port     = $arguments_vhost
  }
  if $path {
    $check_command_path = "${check_command_port}_url"
    $arguments_path     = "${arguments_port}|${path}"
  } else {
    $check_command_path = $check_command_port
    $arguments_path     = $arguments_port
  }
  if $response {
    $check_command_response = "${check_command_path}_response"
    $arguments_response     = "${arguments_path}|${response}"
  } else {
    $check_command_response = $check_command_path
    $arguments_response     = $arguments_path
  }
  if $credentials {
    $check_command_creds = "${check_command_response}_login"
    $arguments_creds     = "${arguments_response}|${credentials}"
  } else {
    $check_command_creds = $check_command_response
    $arguments_creds     = $arguments_response
  }
  if $ssl {
    $check_command_ssl = "${check_command_creds}_ssl"
    $arguments_ssl     = $arguments_creds
  } else {
    $check_command_ssl = $check_command_creds
    $arguments_ssl     = $arguments_creds
  }
  if $address == false or $address == '*' {
    $real_check_command = $check_command_ssl
    $real_arguments     = split("${arguments_ssl}|${real_statuscode}", '[|]')
  } else {
    $real_check_command = "${check_command_ssl}_address"
    $real_arguments     = split("${address}|${arguments_ssl}|${real_statuscode}", '[|]')
  }

  kbp_icinga::service { "vhost_${name}":
    conf_dir             => $confdir,
    service_description  => $service_description ? {
      false   => $ssl ? {
        false => "Vhost ${real_name}",
        true  => "Vhost ${real_name} SSL",
      },
      default => $service_description,
    },
    host_name            => $vhost ? {
      true  => $fqdn,
      false => $real_name,
    },
    # Passing the address to be able to determine to which host the service belongs in the case of multiple hosts with the same name, not used in the actual Icinga config.
    address              => $address,
    check_command        => $real_check_command,
    max_check_attempts   => $max_check_attempts,
    arguments            => $real_arguments,
    ha                   => $ha,
    proxy                => $proxy,
    preventproxyoverride => $preventproxyoverride,
    check_interval       => $check_interval;
  }

  if $ssl {
    kbp_icinga::service { "vhost_${name}_cert":
      conf_dir             => $confdir,
      service_description  => $service_description ? {
        false   => "Vhost ${real_name} SSL cert",
        default => $service_description,
      },
      host_name            => $vhost ? {
        true  => $fqdn,
        false => $real_name,
      },
      # Passing the address to be able to determine to which host the service belongs in the case of multiple hosts with the same name, not used in the actual Icinga config.
      address              => $address,
      check_command        => 'check_http_cert',
      arguments            => $real_name,
      max_check_attempts   => $max_check_attempts,
      ha                   => $ha,
      proxy                => $proxy,
      preventproxyoverride => $preventproxyoverride,
      check_interval       => $check_interval;
    }
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
define kbp_icinga::http($customfqdn=$::fqdn, $auth=false, $proxy=false, $preventproxyoverride=false, $ssl = false) {
  kbp_icinga::service { "http_${customfqdn}":
    conf_dir             => "${::environment}/${customfqdn}",
    service_description  => "HTTP",
    host_name            => $customfqdn,
    check_command        => $ssl ? {
      false   => "check_http",
      default => 'check_http_ssl',
    },
    arguments            => "200,301,302,401,403,404",
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
define kbp_icinga::proc_status ($servicegroups=false) {
  kbp_icinga::service { "proc_status_${name}":
    service_description => "Process status for ${name}",
    check_command       => "check_proc_status",
    servicegroups       => $servicegroups,
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
define kbp_icinga::glassfish::status_page($port, $statuspath=false, $response='200', $check_on_localhost=false, $servicegroups=false) {
  $realpath = $statuspath ? {
    false   => "/${name}/status.jsp",
    default => $statuspath,
  }

  $nrpe = $check_on_localhost ? {
    false   => '',
    default => '_nrpe',
  }

  kbp_icinga::service { "glassfish_instance_${name}_status_page":
    service_description => "Glassfish instance ${name} status page",
    check_command       => "check_http_port_url${nrpe}",
    servicegroups       => $servicegroups,
    arguments           => [$port,$realpath,$response];
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

# Class: kbp_icinga::tomcat
#
# Parameters:
#  monitoring_password:
#    The password for the monitoring user in the manager webapp
#  ajp_port:
#    The AJP connector port
#
class kbp_icinga::tomcat ($monitoring_password) {
  include gen_base::libxml_xpath_perl
  include gen_base::libwww-perl

  kbp_icinga::service { "tomcat_status":
    service_description => 'Status of the tomcat service',
    check_command       => 'check_tomcat',
    arguments           => $monitoring_password;
  }
}

# Define: kbp_icinga::tomcat::application
#
# Parameters:
#  monitoring_password:
#    The password for the monitoring user in the manager webapp
#
define kbp_icinga::tomcat::application ($monitoring_password) {
   kbp_icinga::service { "tomcat_app_${name}_status":
    service_description => "Status of the tomcat application ${name}",
    check_command       => 'check_tomcat_application',
    arguments           => [$monitoring_password, $name];
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

define kbp_icinga::contact($c_alias, $contact_data=false, $notification_type=false, $conf_dir="${environment}/${fqdn}", $timeperiod="24x7", $contactgroups=false,
    $host_notifications_enabled=1, $service_notifications_enabled=1, $ensure='present', $service_notification_options='w,u,c,r', $host_notification_options='d,u,r') {
  $real_notification_type = $contact_data ? {
    false   => "no-notify",
    default => $notification_type ? {
      false   => "email",
      default => $notification_type,
    },
  }

  if $::monitoring == "true" {
    gen_icinga::contact { $name:
      c_alias                       => $c_alias,
      contact_data                  => $contact_data,
      notification_type             => $real_notification_type,
      conf_dir                      => $conf_dir,
      timeperiod                    => $timeperiod,
      contactgroups                 => $contactgroups,
      service_notification_options  => $service_notification_options,
      host_notification_options     => $host_notification_options,
      host_notification_period      => $timeperiod,
      service_notification_period   => $timeperiod,
      service_notification_commands => "notify-service-by-${real_notification_type}",
      host_notification_commands    => "notify-host-by-${real_notification_type}",
      pager                         => $notification_type ? {
        'sms' => $contact_data,
        false => false,
      },
      email                         => $notification_type ? {
        'sms' => false,
        false => $contact_data,
      };
    }
  }
}
