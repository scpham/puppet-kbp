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
			checkcommand        => "check_disk_space",
			nrpe                => true;
		"ksplice_${fqdn}":
			service_description => "Ksplice update status",
			checkcommand        => "check_ksplice",
			nrpe                => true;
		"puppet_state_${fqdn}":
			service_description => "Puppet state freshness",
			checkcommand        => "check_puppet_state_freshness",
			nrpe                => true;
		"cpu_${fqdn}":
			service_description => "CPU usage",
			checkcommand        => "check_cpu",
			nrpe                => true;
#		"loadtrend_${fqdn}":
#			service_description => "Load average",
#			checkcommand        => "check_loadtrend",
#			nrpe                => true;
		"open_files_${fqdn}":
			service_description => "Open files",
			checkcommand        => "check_open_files",
			nrpe                => true;
		"memory_${fqdn}":
			service_description => "Memory usage",
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
#		"/usr/lib/nagios/plugins/check_mysql":
#			source  => "gen_icinga/client/check_mysql",
#			mode    => 755,
#			require => Package["nagios-plugins-kumina"];
	}
}

class kbp_icinga::server {
	include gen_icinga::server

	gen_apt::preference { ["icinga","icinga-core","icinga-cgi","icinga-common","icinga-doc"]:; }

	gen_icinga::servercommand {
		["check_ssh","check_smtp"]:
			conf_dir => "generic";
		["check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd","check_pacemaker","check_mysql","check_mysql_slave","check_loadtrend"]:
			conf_dir => "generic",
			nrpe     => true;
		"check-host-alive":
			conf_dir    => "generic",
			commandname => "check_ping",
			argument1   => "-w 5000,100%",
			argument2   => "-c 5000,100%",
			argument3   => "-p 1";
		"check_http":
			conf_dir    => "generic",
			commandname => "check_http",
			argument1   => '-I $HOSTADDRESS$';
		"check_http_vhost":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$';
		"check_http_vhost_url_and_response":
			conf_dir      => "generic",
			commandname   => "check_http",
			host_argument => '-I $HOSTADDRESS$',
			argument1     => '-H $ARG1$',
			argument2     => '-u $ARG2$',
			argument3     => '-r $ARG3$';
		"check_tcp":
			conf_dir    => "generic",
			commandname => "check_tcp",
			argument1   => '-p $ARG1$';
		"check_nfs":
			conf_dir    => "generic",
			commandname => "check_rpc",
			argument1   => "-C nfs -c2,3";
		"check_sslcert":
			conf_dir  => "generic",
			argument1 => '$ARG1$',
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

	gen_icinga::service {
		"generic_ha_service":
			conf_dir                     => "generic",
			use                          => "false",
			initialstate                 => "u",
			active_checks_enabled        => "1",
			passive_checks_enabled       => "1",
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
			contact_groups               => "kumina_email, kumina_sms",
			register                     => "0";
		"generic_wh_service":
			conf_dir            => "generic",
			use                 => "generic_ha_service",
			notification_period => "workhours",
			register            => "0";
		"generic_passive_service":
			conf_dir              => "generic",
			use                   => "generic_ha_service",
			checkcommand          => "return-ok",
			active_checks_enabled => "0",
			max_check_attempts    => "1",
			check_freshness       => "1",
			freshnessthreshold    => "360",
			register              => "0";
	}

	gen_icinga::host {
		"generic_ha_host":
			conf_dir                     => "generic",
			use                          => "false",
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
			contact_groups               => "kumina",
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
}

define kbp_icinga::haproxy ($address) {
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
