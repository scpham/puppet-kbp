class kbp_icinga::client {
	include gen_icinga::client

	gen_icinga::configdir { "${environment}/${fqdn}":
		sub => $environment;
	}

	gen_icinga::host { "${fqdn}":
		parents => $parent;
	}

	gen_icinga::service {
		"ssh_${fqdn}":
			service_description => "SSH connectivity",
			checkcommand        => "check_ssh";
		"disk_space_${fqdn}":
			service_description => "Disk space",
			servicegroups       => "wh_services_critsms",
			checkcommand        => "check_disk_space",
			nrpe                => true;
		"ksplice_${fqdn}":
			service_description => "Ksplice update status",
			checkcommand        => "check_ksplice",
			nrpe                => true;
		"puppet_state_${fqdn}":
			service_description => "Puppet state freshness",
			servicegroups       => "mail_services",
			checkcommand        => "check_puppet_state_freshness",
			nrpe                => true;
		"cpu_${fqdn}":
			service_description  => "CPU usage",
			checkcommand         => "check_cpu",
			retry_check_interval => 5,
			max_check_attempts   => 30,
			nrpe                 => true;
		"loadtrend_${fqdn}":
			service_description  => "Load trend",
			checkcommand         => "check_loadtrend",
			retry_check_interval => 5,
			max_check_attempts   => 30,
			nrpe                 => true;
		"open_files_${fqdn}":
			service_description => "Open files",
			checkcommand        => "check_open_files",
			nrpe                => true;
		"ntp_offset_${fqdn}":
			service_description => "NTP offset",
			servicegroups       => "mail_services",
			checkcommand        => "check_remote_ntp",
			nrpe                => true;
		"ntpd_${fqdn}":
			service_description => "NTPD",
			servicegroups       => "mail_services",
			checkcommand        => "check_ntpd",
			nrpe                => true;
		"memory_${fqdn}":
			service_description => "Memory usage",
			servicegroups       => "wh_services_critsms",
			checkcommand        => "check_memory",
			nrpe                => true;
		"zombie_processes_${fqdn}":
			service_description => "Zombie processes",
			checkcommand        => "check_zombie_processes",
			nrpe                => true;
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
	}
}

class kbp_icinga::server {
	include gen_icinga::server
	include kbp_nsca::server

	gen_apt::preference { ["icinga","icinga-core","icinga-cgi","icinga-common","icinga-doc"]:; }

	gen_icinga::servercommand {
		["check_ssh","check_smtp"]:
			conf_dir => "generic";
		["check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd","check_pacemaker","check_mysql","check_mysql_slave","check_loadtrend","check_heartbeat","check_ntpd","check_remote_ntp","check_coldfusion","check_dhcp","check_arpwatch"]:
			conf_dir => "generic",
			nrpe     => true;
		"return-ok":
			conf_dir      => "generic",
			commandname   => "check_dummy",
			host_argument => false,
			argument1     => "0";
		"check-host-alive":
			conf_dir    => "generic",
			commandname => "check_ping",
			argument1   => "-w 5000,100%",
			argument2   => "-c 5000,100%",
			argument3   => "-p 1";
		"check_http":
			conf_dir  => "generic",
			argument1 => '-I $HOSTADDRESS$';
		"check_http_vhost":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$';
		"check_http_vhost_auth":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$',
			argument2     => "-e 401,403";
		"check_http_vhost_and_url":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			argument1     => '-u $ARG1$';
		"check_http_vhost_url_and_response":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			argument1     => '-u $ARG1$',
			argument2     => '-r $ARG2$';
		"check_http_on_port_with_vhost_url_and_response":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$ -H $HOSTNAME$',
			argument1     => '-p $ARG1$',
			argument2     => '-u $ARG2$',
			argument3     => '-r $ARG3$';
		"check_tcp":
			conf_dir  => "generic",
			argument1 => '-p $ARG1$';
		"check_nfs":
			conf_dir    => "generic",
			commandname => "check_rpc",
			argument1   => "-C nfs -c2,3";
		"check_sslcert":
			conf_dir  => "generic",
			argument1 => '$ARG1$',
			nrpe      => true;
		"check_ssl_cert":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => "-t 20",
			argument2     => '-H $ARG1$',
			argument3     => "-C 30";
		"check_java_heap_usage":
			conf_dir  => "generic",
			argument1 => '$ARG1$',
			nrpe      => true;
		"check_imaps":
			conf_dir    => "generic",
			commandname => "check_imap",
			argument1   => "-p 993",
			argument2   => "-S";
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

	gen_icinga::service {
		"generic_ha_service":
			conf_dir                     => "generic",
			use                          => false,
			servicegroups                => "ha_services",
			initialstate                 => "u",
			active_checks_enabled        => "1",
			passive_checks_enabled       => "0",
			parallelize_check            => "1",
			obsess_over_service          => "1",
			check_freshness              => "0",
			notifications_enabled        => "1",
			event_handler_enabled        => "1",
			flap_detection_enabled       => "1",
			failure_prediction_enabled   => "1",
			process_perf_data            => "1",
			retain_status_information    => "1",
			retain_nonstatus_information => "1",
			notification_interval        => "0",
			is_volatile                  => "0",
			check_period                 => "24x7",
			normal_check_interval        => "300",
			retry_check_interval         => "10",
			max_check_attempts           => "3",
			notification_period          => "24x7",
			notification_options         => "w,u,c,r",
			contact_groups               => "kumina_email",
			register                     => "0";
		"generic_wh_service":
			conf_dir            => "generic",
			use                 => "generic_ha_service",
			servicegroups       => "wh_services_warnsms",
			notification_period => "workhours",
			register            => "0";
		"generic_passive_service":
			conf_dir               => "generic",
			use                    => "generic_wh_service",
			servicegroups          => "wh_services_warnsms",
			active_checks_enabled  => "0",
			passive_checks_enabled => "1",
			checkcommand           => "return-ok",
			notification_period    => "workhours",
			register               => "0";
	}

	gen_icinga::host {
		"generic_ha_host":
			conf_dir                     => "generic",
			use                          => false,
			hostgroups                   => "ha_hosts",
			initialstate                 => "u",
			notifications_enabled        => "1",
			event_handler_enabled        => "0",
			flap_detection_enabled       => "1",
			process_perf_data            => "1",
			retain_status_information    => "1",
			retain_nonstatus_information => "1",
			check_command                => "check-host-alive",
			check_interval               => "120",
			notification_period          => "24x7",
			notification_interval        => "36000",
			contact_groups               => "kumina_email",
			max_check_attempts           => "3",
			register                     => "0";
		"generic_wh_host":
			conf_dir   => "generic",
			use        => "generic_ha_host",
			hostgroups => "wh_hosts",
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
}

class kbp_icinga::heartbeat {
	gen_icinga::service { "heartbeat_${fqdn}":
		service_description => "Heartbeat",
		checkcommand        => "check_heartbeat",
		nrpe                => true;
	}
}

class kbp_icinga::nfs {
	gen_icinga::service { "nfs_daemon_${fqdn}":
		service_description => "NFS daemon",
		checkcommand        => "check_nfs";
	}
}

class kbp_icinga::dhcp {
	gen_icinga::service { "dhcp_daemon_${fqdn}":
		service_description => "DHCP daemon",
		checkcommand        => "check_dhcp";
	}
}

define kbp_icinga::sslcert($path) {
	gen_icinga::service { "ssl_cert_${name}_${fqdn}":
		service_description => "SSL certificate in ${path}",
		servicegroups       => "wh_services_critsms",
		checkcommand        => "check_sslcert",
		argument1           => $path,
		nrpe                => true;
	}
}

define kbp_icinga::virtualhost($address, $conf_dir=$environment, $parents=false) {
	gen_icinga::configdir { "${conf_dir}/${name}":
		sub => $conf_dir;
	}

	gen_icinga::host { "${name}":
		conf_dir => "${conf_dir}/${name}",
		address  => $address,
		parents  => $parents ? {
			false   => undef,
			default => $parents,
		};
	}
}

define kbp_icinga::haproxy($address) {
	$confdir = "${environment}/${name}"

	gen_icinga::configdir { $confdir:
		sub => $environment;
	}

	gen_icinga::host { "${name}":
		address => $address,
		parents => $loadbalancer::otherhost ? {
			undef   => $fqdn,
			default => "${fqdn}, ${loadbalancer::otherhost}",
		}
	}

	gen_icinga::service { "virtual_host_${name}":
		conf_dir            => $confdir,
		service_description => "Virtual host ${name}",
		hostname            => $name,
		checkcommand        => "check_http_vhost",
		argument1           => $name;
	}
}

define kbp_icinga::java($contact_groups=false, $servicegroups=false) {
	gen_icinga::service { "java_heap_usage_${name}_${fqdn}":
		service_description => "Java heap usage ${name}",
		checkcommand        => "check_java_heap_usage",
		argument1           => $name,
		contact_groups      => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		servicegroups       => $servicegroups ? {
			false   => undef,
			default => $servicegroups,
		},
		nrpe                => true;
	}
}

define kbp_icinga::site($address=false, $conf_dir=false, $parents=$fqdn, $auth=false) {
	if $address {
		if $conf_dir {
			$confdir = "${conf_dir}/${name}"

			gen_icinga::configdir { $confdir:
				sub => $conf_dir;
			}
		} else {
			$confdir = "${environment}/${name}"

			gen_icinga::configdir { $confdir:
				sub => $environment;
			}
		}

		gen_icinga::host { "${name}":
			address => $address,
			parents => $parents;
		}

		gen_icinga::service { "vhost_${name}":
			conf_dir            => $confdir,
			service_description => "Vhost ${name}",
			hostname            => $name,
			checkcommand        => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			argument1           => $name;
		}
	} else {
		gen_icinga::service { "vhost_${name}_${fqdn}":
			service_description => "Vhost ${name}",
			checkcommand        => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			argument1           => $name;
		}
	}
}

define kbp_icinga::sslsite($conf_dir=false) {
	gen_icinga::service { "ssl_site_${name}_${fqdn}":
		service_description => "SSL validity ${name}",
		checkcommand        => "check_ssl_cert",
		argument1           => "${name}";
	}
}
