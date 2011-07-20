# Author: Kumina bv <support@kumina.nl>

# Class: kbp_icinga::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_icinga::client {
	include gen_icinga::client

	clientcommand {
		["check_cassandra","check_heartbeat"]:;
		"check_3ware":
			sudo => true;
		"check_adaptec":
			sudo => true;
		"check_arpwatch":
			command   => "check_procs",
			arguments => "-c 1: -C arpwatch";
		"check_asterisk":
			sudo      => true,
			command   => "check_asterisk",
			arguments => "signet";
		"check_cpu":
			arguments => "-w 90 -c 95";
		"check_dhcp":
			command   => "check_procs",
			arguments => "-c 1: -C dhcpd3";
		"check_disk_space":
			sudo      => true,
			command   => "check_disk",
			arguments => "-W 10% -K 5% -w 10% -c 5% -l --errors-only";
		"check_dnszone":
			arguments => '$ARG1$ $ARG2$';
		"check_drbd":
			arguments => "-d All";
		"check_java_heap_usage":
			command   => "check_javaheapusage",
			arguments => '/etc/munin/plugins/jmx_$ARG1$_java_process_memory 90 80';
		"check_ksplice":
			command   => "check_uptrack_local",
			arguments => "-w i -c o";
		"check_loadtrend":
			arguments => "-m 1.5 -c 5 -w 2.5";
		"check_mbean_value":
			arguments => '$ARG1$ $ARG2$ $ARG3$ $ARG4$';
		"check_memory":
			arguments => "-w 6 -c 3";
		"check_mysql":
			arguments => "-u nagios";
		"check_mysql_slave":
			command   => "check_mysql",
			arguments => "-u nagios -S";
		"check_ntpd":
			command   => "check_procs",
			arguments => "-c 1: -C ntpd";
		"check_open_files":
			arguments => "-w 90 -c 95";
		"check_pacemaker":
			sudo      => true,
			path      => "/usr/sbin/",
			command   => "crm_mon",
			arguments => "-s";
		"check_proc_status":
			sudo      => true,
			arguments => '$ARG1$';
		"check_puppet_state_freshness":
			command   => "check_file_age",
			arguments => "-f /var/lib/puppet/state/state.yaml -w 14400 -c 21600";
		"check_remote_ntp":
			command   => "check_ntp_time",
			arguments => "-H 0.debian.pool.ntp.org";
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

	gen_icinga::configdir { "${environment}/${fqdn}":; }

	kbp_icinga::host { "${fqdn}":
		parents => $parent;
	}

	kbp_icinga::service {
		"ssh":
			service_description => "SSH connectivity",
			check_command       => "check_ssh";
		"disk_space":
			service_description => "Disk space",
			check_command       => "check_disk_space",
			nrpe                => true,
			warnsms             => false;
		"ksplice":
			service_description => "Ksplice update status",
			check_command       => "check_ksplice",
			nrpe                => true;
		"puppet_state":
			service_description => "Puppet state freshness",
			check_command       => "check_puppet_state_freshness",
			nrpe                => true,
			sms                 => false;
		"cpu":
			ensure              => absent,
			service_description => "CPU usage",
			check_command       => "check_cpu",
			retry_interval      => 10,
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
		"ntp_offset":
			service_description => "NTP offset",
			check_command       => "check_remote_ntp",
			nrpe                => true,
			sms                 => false;
		"ntpd":
			service_description => "NTPD",
			check_command       => "check_ntpd",
			nrpe                => true,
			sms                 => false;
		"memory":
			service_description => "Memory usage",
			check_command       => "check_memory",
			nrpe                => true,
			warnsms             => false;
		"swap":
			service_description => "Swap usage",
			check_command       => "check_swap",
			nrpe                => true,
			warnsms             => false;
		"zombie_processes":
			service_description => "Zombie processes",
			check_command       => "check_zombie_processes",
			nrpe                => true;
	}

	gen_sudo::rule { "Icinga can run all plugins as root":
		entity            => "nagios",
		as_user           => "root",
		password_required => false,
		command           => ["/usr/lib/nagios/plugins/", "/usr/local/lib/nagios/plugins/"];
	}

	kfile {
		"/usr/lib/nagios/plugins/check_cpu":
			source  => "gen_icinga/client/check_cpu",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_open_files":
			source  => "gen_icinga/client/check_open_files",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_memory":
			source  => "gen_icinga/client/check_memory",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_drbd":
			source  => "gen_icinga/client/check_drbd",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_heartbeat":
			source  => "gen_icinga/client/check_heartbeat",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_dnszone":
			source  => "gen_icinga/client/check_dnszone",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_cassandra":
			source  => "gen_icinga/client/check_cassandra",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_proc_status":
			source  => "gen_icinga/client/check_proc_status",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_adaptec":
			source  => "gen_icinga/client/check_adaptec",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_mbean_value":
			source  => "gen_icinga/client/check_mbean_value",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_3ware":
			source  => "gen_icinga/client/check_3ware",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_asterisk":
			source  => "gen_icinga/client/check_asterisk",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
	}

	define clientcommand($sudo=false, $path=false, $command=false, $arguments=false) {
		kfile { "/etc/nagios/nrpe.d/${name}.cfg":
			content => template("kbp_icinga/clientcommand"),
			require => Package["nagios-nrpe-server"];
		}
	}
}

# Class: kbp_icinga::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_icinga::server {
	include gen_icinga::server
	include kbp_nsca::server

	gen_apt::preference { ["icinga","icinga-core","icinga-cgi","icinga-common","icinga-doc"]:; }

	gen_icinga::servercommand {
		["check_ssh","check_smtp"]:
			conf_dir => "generic";
		["check_asterisk","check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd","check_pacemaker","check_mysql","check_mysql_slave","check_loadtrend","check_heartbeat","check_ntpd","check_remote_ntp","check_coldfusion","check_dhcp","check_arpwatch","check_3ware","check_adaptec","check_cassandra","check_swap"]:
			conf_dir => "generic",
			nrpe     => true;
		"return-ok":
			conf_dir      => "generic",
			command_name  => "check_dummy",
			host_argument => false,
			arguments     => "0";
		"check-host-alive":
			conf_dir     => "generic",
			command_name => "check_ping",
			arguments    => ["-w 5000,100%","-c 5000,100%","-p 1"];
		"check_http":
			conf_dir  => "generic",
			arguments => '-I $HOSTADDRESS$';
		"check_http_auth":
			conf_dir     => "generic",
			command_name => "check_http",
			arguments    => ['-I $HOSTADDRESS$',"-e 401,403"];
		"check_http_vhost":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			arguments     => '-H $ARG1$';
		"check_http_vhost_auth":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			arguments     => ['-H $ARG1$',"-e 401,403"];
		"check_http_vhost_and_url":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			arguments     => '-u $ARG1$';
		"check_http_vhost_url_and_response":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			arguments     => ['-u $ARG1$','-r $ARG2$'];
		"check_http_on_port_with_vhost_url_and_response":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			arguments     => ['-p $ARG1$','-u $ARG2$','-r $ARG3$'];
		"check_mbean_value":
			conf_dir  => "generic",
			arguments => ['$ARG1$','$ARG2$','$ARG3$','$ARG4$'],
			nrpe      => true;
		"check_tcp":
			conf_dir  => "generic",
			arguments => '-p $ARG1$';
		"check_nfs":
			conf_dir     => "generic",
			command_name => "check_rpc",
			arguments    => "-C nfs -c2,3";
		"check_sslcert":
			conf_dir  => "generic",
			arguments => '$ARG1$',
			nrpe      => true;
		"check_proc_status":
			conf_dir  => "generic",
			arguments => '$ARG1$',
			nrpe      => true;
		"check_ssl_cert":
			conf_dir      => "generic",
			command_name  => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			arguments     => ["-t 20",'-H $ARG1$',"-C 30"];
		"check_java_heap_usage":
			conf_dir  => "generic",
			arguments => '$ARG1$',
			nrpe      => true;
		"check_imaps":
			conf_dir     => "generic",
			command_name => "check_imap",
			arguments    => ["-p 993","-S"];
		"check_dnszone":
			conf_dir  => "generic",
			arguments => ['$ARG1$','$ARG2$'],
			nrpe      => true;
	}

	kfile {
		"/etc/icinga/cgi.cfg":
			source  => "kbp_icinga/server/cgi.cfg",
			notify  => Exec["reload-icinga"],
			require => Package["icinga"];
		"/etc/icinga/icinga.cfg":
			source  => "kbp_icinga/server/icinga.cfg",
			notify  => Exec["reload-icinga"],
			require => Package["icinga"];
		"/etc/icinga/config":
			ensure  => directory,
			require => Package["icinga"];
		"/etc/icinga/config/generic":
			ensure  => directory;
		"/etc/icinga/config/generic/notify_commands.cfg":
			source  => "kbp_icinga/server/config/generic/notify_commands.cfg",
			notify  => Exec["reload-icinga"];
	}

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
			check_interval               => "10",
			retry_interval               => "10",
			max_check_attempts           => "3",
			notification_options         => "w,u,c,r",
			contacts                     => "devnull",
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
			check_command                => "check-host-alive",
			check_interval               => "10",
			notification_period          => "24x7",
			notification_interval        => "600",
			contacts                     => "devnull",
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

	gen_icinga::contactgroup { "devnull":
		conf_dir => "generic",
		cg_alias => "No notify contacts";
	}

	gen_icinga::contact { "devnull":
		conf_dir                      => "generic",
		c_alias                       => "No notify contact",
		host_notifications_enabled    => 0,
		service_notifications_enabled => 0,
		contact_data                  => false;
	}
}

# Class: kbp_icinga::environment
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_icinga::environment {
	gen_icinga::configdir { ["${environment}","${environment}/generic"]:; }

	gen_icinga::contactgroup { "${environment}_email":
		conf_dir => "${environment}/generic",
		cg_alias => "${environment} contacts";
	}

	gen_icinga::contact { "${environment}_email":
		conf_dir      => "${environment}/generic",
		c_alias       => "${environment} email",
		contactgroups => "${environment}_email",
		contact_data  => false;
	}

	gen_icinga::hostgroup { "${environment}_hosts":
		conf_dir => "${environment}/generic",
		hg_alias => "${environment} servers";
	}

	@gen_icinga::hostescalation { "${environment}_mail":
		conf_dir              => "${environment}/generic",
		hostgroup_name        => "${environment}_hosts",
		first_notification    => 1,
		last_notification     => 1,
		notification_interval => 600,
		escalation_period     => "24x7",
		contact_groups        => "${environment}_email";
	}

	gen_icinga::servicegroup { "${environment}_services":
		conf_dir => "${environment}/generic",
		sg_alias => "${environment} services";
	}

	@gen_icinga::serviceescalation { "${environment}_mail":
		conf_dir              => "${environment}/generic",
		hostgroup_name        => "${environment}_hosts",
		first_notification    => 1,
		last_notification     => 1,
		notification_interval => 600,
		escalation_period     => "24x7",
		contact_groups        => "${environment}_email";
	}
}

# Class: kbp_icinga::heartbeat
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_icinga::heartbeat {
	kbp_icinga::service { "heartbeat":
		service_description => "Heartbeat",
		check_command       => "check_heartbeat",
		nrpe                => true;
	}
}

# Class: kbp_icinga::nfs
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_icinga::nfs {
	kbp_icinga::service { "nfs_daemon":
		service_description => "NFS daemon",
		check_command       => "check_nfs";
	}
}

# Class: kbp_icinga::dhcp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
#	Set up asterisk monitoring
#
class kbp_icinga::asterisk {
	kbp_icinga::service { "asterisk":
		service_description => "Asterisk status",
		check_command       => "check_asterisk",
		nrpe                => true;
	}
}

# Define: kbp_icinga::service
#
# Parameters:
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::service($service_description=false, $use=false, $servicegroups=false, $passive=false, $ha=false, $sms=true, $warnsms=true, $conf_dir="${environment}/${fqdn}",
		$host_name=$fqdn, $initial_state=false, $active_checks_enabled=false, $passive_checks_enabled=false, $obsess_over_service=false, $check_freshness=false,
		$freshness_threshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false,
		$retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false, $check_interval=false, $retry_interval=false,
		$notification_period=false, $notification_options=false, $contact_groups=false, $contacts=false, $max_check_attempts=false, $check_command=false,
		$arguments=false, $register=false, $nrpe=false, $ensure=present) {
	$real_use = $use ? {
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
		$environment => $passive ? {
			true  => "${environment}_passive_service",
			false => "${environment}_service",
		},
		" "            => false,
		default        => $use,
	}
	$real_name = $conf_dir ? {
		"generic" => $name,
		default   => "${name}_${host_name}",
	}

	if $ha {
		Gen_icinga::Host <| title == $host_name |> {
			hostgroups => "ha_hosts",
		}
	}

	gen_icinga::service { "${real_name}":
		conf_dir                     => $conf_dir,
		use                          => $real_use,
		servicegroups                => $servicegroups ? {
			false   => undef,
			default => $servicegroups,
		},
		service_description          => $service_description ? {
			false   => undef,
			default => $service_description,
		},
		check_command                => $check_command ? {
			false   => undef,
			default => $check_command,
		},
		host_name                    => $register ? {
			0       => undef,
			default => $host_name,
		},
		initial_state                => $initial_state ? {
			false   => undef,
			default => $initial_state,
		},
		active_checks_enabled        => $active_checks_enabled ? {
			false   => undef,
			default => $active_checks_enabled,
		},
		passive_checks_enabled       => $passive_checks_enabled ? {
			false   => undef,
			default => $passive_checks_enabled,
		},
		obsess_over_service          => $obsess_over_service ? {
			false   => undef,
			default => $obsess_over_service,
		},
		check_freshness              => $check_freshness ? {
			false   => undef,
			default => $check_freshness,
		},
		freshness_threshold          => $freshness_threshold ? {
			false   => undef,
			default => $freshness_threshold,
		},
		notifications_enabled        => $notifications_enabled ? {
			false   => undef,
			default => $notifications_enabled,
		},
		event_handler_enabled        => $event_handler_enabled ? {
			false   => undef,
			default => $event_handler_enabled,
		},
		flap_detection_enabled       => $flap_detection_enabled ? {
			false   => undef,
			default => $flap_detection_enabled,
		},
		process_perf_data            => $process_perf_data ? {
			false   => undef,
			default => $process_perf_data,
		},
		retain_status_information    => $retain_status_information ? {
			false   => undef,
			default => $retain_status_information,
		},
		retain_nonstatus_information => $retain_nonstatus_information ? {
			false   => undef,
			default => $retain_nonstatus_information,
		},
		notification_interval        => $notification_interval ? {
			false   => undef,
			default => $notification_interval,
		},
		is_volatile                  => $is_volatile ? {
			false   => undef,
			default => $is_volatile,
		},
		check_period                 => $check_period ? {
			false   => undef,
			default => $check_period,
		},
		check_interval               => $check_interval ? {
			false   => undef,
			default => $check_interval,
		},
		retry_interval               => $retry_interval ? {
			false   => undef,
			default => $retry_interval,
		},
		notification_period          => $notification_period ? {
			false   => undef,
			default => $notification_period,
		},
		notification_options         => $notification_options ? {
			false   => undef,
			default => $notification_options,
		},
		contact_groups               => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		contacts                     => $contacts ? {
			false   => undef,
			default => $contacts,
		},
		max_check_attempts           => $max_check_attempts ? {
			false   => undef,
			default => $max_check_attempts,
		},
		arguments                    => $arguments ? {
			false   => undef,
			default => $arguments,
		},
		register                     => $register ? {
			false   => undef,
			default => $register,
		},
		nrpe                         => $nrpe ? {
			false   => undef,
			default => $nrpe,
		},
		ensure                       => $ensure;
	}
}

# Define: kbp_icinga::host
#
# Parameters:
#	Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	gen_puppet
define kbp_icinga::host($conf_dir="${environment}/${name}", $sms=true, $use=false, $hostgroups="wh_hosts", $parents=false, $address=$ipaddress,
		$initial_state=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false,
		$retain_nonstatus_information=false, $check_command=false, $check_interval=false, $notification_period=false, $notification_interval=false, $contact_groups=false,
		$contacts=false, $max_check_attempts=false, $register=1) {
	$real_use = $use ? {
		false   => $sms ? {
			true  => "wh_host",
			false => "mail_host",
		},
		" "     => false,
		default => $use,
	}

	gen_icinga::host { "${name}":
		conf_dir                     => $conf_dir,
		use                          => $real_use,
		hostgroups                   => $hostgroups,
		parents                      => $parents ? {
			false   => undef,
			default => $parents,
		},
		address   => $address,
		initial_state                => $initial_state ? {
			false   => undef,
			default => $initialstate,
		},
		notifications_enabled        => $notifications_enabled ? {
			false   => undef,
			default => $notifications_enabled,
		},
		event_handler_enabled        => $event_handler_enabled ? {
			false   => undef,
			default => $event_handler_enabled,
		},
		flap_detection_enabled       => $flap_detection_enabled ? {
			false   => undef,
			default => $flap_detection_enabled,
		},
		process_perf_data            => $process_perf_data ? {
			false   => undef,
			default => $process_perf_data,
		},
		retain_status_information    => $retain_status_information ? {
			false   => undef,
			default => $retain_status_information,
		},
		retain_nonstatus_information => $retain_nonstatus_information ? {
			false   => undef,
			default => $retain_nonstatus_information,
		},
		check_command                => $check_command ? {
			false   => undef,
			default => $check_command,
		},
		check_interval               => $check_interval ? {
			false   => undef,
			default => $check_interval,
		},
		notification_period          => $notification_period ? {
			false   => undef,
			default => $notification_period,
		},
		notification_interval        => $notification_interval ? {
			false   => undef,
			default => $notification_interval,
		},
		contact_groups               => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		contacts                     => $contacts ? {
			false   => undef,
			default => $contacts,
		},
		max_check_attempts           => $max_check_attempts ? {
			false   => undef,
			default => $max_check_attempts,
		},
		register                     => $register;
	}
}

# Define: kbp_icinga::sslcert
#
# Parameters:
#	path
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::sslcert($path) {
	kbp_icinga::service { "ssl_cert_${name}":
		service_description => "SSL certificate in ${path}",
		check_command       => "check_sslcert",
		arguments           => $path,
		nrpe                => true;
	}
}

# Define: kbp_icinga::virtualhost
#
# Parameters:
#	conf_dir
#		Undocumented
#	environment
#		Undocumented
#	parents
#		Undocumented
#	hostgroups
#		Undocumented
#	contact_groups
#		Undocumented
#	address
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::virtualhost($address, $conf_dir=$environment, $parents=false, $hostgroups=false, $contact_groups=false, $sms=true) {
	$confdir = "${conf_dir}/${name}"

	gen_icinga::configdir { "${confdir}":; }

	kbp_icinga::host { "${name}":
		conf_dir       => $confdir,
		address        => $address,
		parents        => $parents ? {
			false   => undef,
			default => $parents,
		},
		hostgroups     => $hostgroups ? {
			false   => undef,
			default => $hostgroups,
		},
		contact_groups => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		sms            => $sms;
	}
}

# Define: kbp_icinga::haproxy
#
# Parameters:
#	ha
#		Undocumented
#	url
#		Undocumented
#	response
#		Undocumented
#	address
#		Undocumented
#	max_check_attempts
#		Number of retries before the monitoring considers the site down.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::haproxy($address, $ha=false, $url=false, $response=false, $max_check_attempts=false) {
	$confdir = "${environment}/${name}"

	gen_icinga::configdir { $confdir:; }

	kbp_icinga::host { "${name}":
		conf_dir   => $confdir,
		address    => $address,
		parents    => $loadbalancer::otherhost ? {
			undef   => $fqdn,
			default => "${fqdn}, ${loadbalancer::otherhost}",
		},
		hostgroups => $ha ? {
			false => undef,
			true  => "ha_hosts",
		};
	}

	if $url and $response {
		kbp_icinga::service { "virtual_host_${name}":
			conf_dir            => $confdir,
			service_description => "Virtual host ${name}",
			host_name           => $name,
			check_command       => "check_http_vhost_url_and_response",
			arguments           => [$url,$response],
			max_check_attempts  => $max_check_attempts,
			ha                  => $ha;
		}
	} else {
		kbp_icinga::service { "virtual_host_${name}":
			conf_dir            => $confdir,
			service_description => "Virtual host ${name}",
			host_name           => $name,
			check_command       => "check_http_vhost",
			arguments           => $name,
			max_check_attempts  => $max_check_attempts,
			ha                  => $ha;
		}
	}
}

# Define: kbp_icinga::java
#
# Parameters:
#	sms
#		Undocumented
#	contact_groups
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::java($contact_groups=false, $sms=true) {
	kbp_icinga::service { "java_heap_usage_${name}":
		service_description => "Java heap usage ${name}",
		check_command       => "check_java_heap_usage",
		arguments           => $name,
		contact_groups      => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		nrpe                => true,
		sms                 => $sms;
	}
}

# Define: kbp_icinga::site
#
# Parameters:
#	conf_dir
#		Undocumented
#	parents
#		Undocumented
#	fqdn
#		Undocumented
#	auth
#		Undocumented
#	address
#		Undocumented
#	max_check_attempts
#		For overriding the default max_check_attempts of the service.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::site($address=false, $conf_dir=false, $parents=$fqdn, $auth=false, $max_check_attempts=false) {
	if $address {
		if $conf_dir {
			$confdir = "${conf_dir}/${name}"

			gen_icinga::configdir { $confdir:; }
		} else {
			$confdir = "${environment}/${name}"

			gen_icinga::configdir { $confdir:; }
		}

		kbp_icinga::host { "${name}":
			conf_dir => $confdir,
			address  => $address,
			parents  => $parents;
		}

		kbp_icinga::service { "vhost_${name}":
			conf_dir            => $confdir,
			service_description => "Vhost ${name}",
			host_name           => $name,
			check_command       => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			max_check_attempts  => $max_check_attempts,
			arguments           => $name;
		}
	} else {
		kbp_icinga::service { "vhost_${name}":
			service_description => "Vhost ${name}",
			check_command       => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			max_check_attempts  => $max_check_attempts,
			arguments           => $name;
		}
	}
}

# Define: kbp_icinga::sslsite
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::sslsite {
	kbp_icinga::service { "ssl_site_${name}":
		service_description => "SSL validity ${name}",
		check_command       => "check_ssl_cert",
		arguments           => $name;
	}
}

# Define: kbp_icinga::raidcontroller
#
# Parameters:
#	driver
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
#	fqdn
#		Undocumented
#	auth
#		Undocumented
#	customfqdn
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::http($customfqdn=$fqdn, $auth=false) {
	kbp_icinga::service { "http_${customfqdn}":
		conf_dir            => "${environment}/${customfqdn}",
		service_description => "HTTP",
		host_name           => $customfqdn,
		check_command       => $auth ? {
			false   => "check_http",
			default => "check_http_auth",
		};
	}
}

# Define: kbp_icinga::proc_status
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
#	statuspath
#		Undocumented
#	webport
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::glassfish($webport, $statuspath=false) {
	$realpath = $statuspath ? {
		false   => "/${name}/status.jsp",
		default => "${statuspath}/status.jsp",
	}

	kbp_icinga::service { "glassfish_${name}":
		service_description => "Glassfish ${name} status",
		check_command       => "check_http_on_port_with_vhost_url_and_response",
		arguments           => [$webport,$realpath,"RUNNING"];
	}
}

# Define: kbp_icinga::mbean_value
#
# Parameters:
#	statuspath
#		Undocumented
#	jmxport
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
		kfile { "/etc/nagios/nrpe.d/mbean_${jmxport}_${attributename}_${expectedvalue}_${attributekey}.conf":
			content => template("kbp_icinga/mbean_value.conf");
		}
	} else {
		kfile { "/etc/nagios/nrpe.d/mbean_${jmxport}_${attributename}_${expectedvalue}.conf":
			content => template("kbp_icinga/mbean_value.conf");
		}
	}
}

# Define: kbp_icinga::dnszone
#
# Parameters:
#	sms
#		Undocumented
#	master
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::dnszone($master, $sms=true) {
	kbp_icinga::service { "dnszone_${name}":
		service_description => "DNS zone ${name} from ${master}",
		check_command       => "check_dnszone",
		arguments           => [$name,$master],
		nrpe                => true,
		sms                 => $sms;
	}
}
