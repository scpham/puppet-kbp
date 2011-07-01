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

	gen_sudo::rule { "Icinga can run all plugins as root":
		entity            => "nagios",
		as_user           => "root",
		password_required => false,
		command           => ["/usr/lib/nagios/plugins/", "/usr/local/lib/nagios/plugins/"];
	}

	gen_icinga::configdir { "${environment}/${fqdn}":
		sub => $environment;
	}

	gen_icinga::host { "${fqdn}":
		parents => $parent;
	}

	kbp_icinga::service {
		"ssh_${fqdn}":
			service_description => "SSH connectivity",
			check_command       => "check_ssh";
		"disk_space_${fqdn}":
			service_description => "Disk space",
			check_command       => "check_disk_space",
			nrpe                => true,
			warnsms             => false;
		"ksplice_${fqdn}":
			service_description => "Ksplice update status",
			check_command       => "check_ksplice",
			nrpe                => true;
		"puppet_state_${fqdn}":
			service_description => "Puppet state freshness",
			check_command       => "check_puppet_state_freshness",
			nrpe                => true,
			sms                 => false;
		"cpu_${fqdn}":
			service_description => "CPU usage",
			check_command       => "check_cpu",
			retry_interval      => 10,
			max_check_attempts  => 30,
			nrpe                => true;
		"loadtrend_${fqdn}":
			service_description => "Load trend",
			check_command       => "check_loadtrend",
			retry_interval      => 10,
			max_check_attempts  => 30,
			nrpe                => true;
		"open_files_${fqdn}":
			service_description => "Open files",
			check_command       => "check_open_files",
			nrpe                => true;
		"ntp_offset_${fqdn}":
			service_description => "NTP offset",
			check_command       => "check_remote_ntp",
			nrpe                => true,
			sms                 => false;
		"ntpd_${fqdn}":
			service_description => "NTPD",
			check_command       => "check_ntpd",
			nrpe                => true,
			sms                 => false;
		"memory_${fqdn}":
			service_description => "Memory usage",
			check_command       => "check_memory",
			nrpe                => true,
			warnsms             => false;
		"zombie_processes_${fqdn}":
			service_description => "Zombie processes",
			check_command       => "check_zombie_processes",
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
		"/usr/lib/nagios/plugins/check_dnszone":
			source  => "gen_icinga/client/check_dnszone",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
		"/usr/lib/nagios/plugins/check_cassandra":
			source  => "gen_icinga/client/check_cassandra",
			mode    => 755,
			require => Package["nagios-plugins-kumina"];
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
		["check_open_files","check_cpu","check_disk_space","check_ksplice","check_memory","check_puppet_state_freshness","check_zombie_processes","check_local_smtp","check_drbd","check_pacemaker","check_mysql","check_mysql_slave","check_loadtrend","check_heartbeat","check_ntpd","check_remote_ntp","check_coldfusion","check_dhcp","check_arpwatch","check_3ware","check_adaptec","check_cassandra"]:
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
		"check_http_auth":
			conf_dir    => "generic",
			commandname => "check_http",
			argument1   => '-I $HOSTADDRESS$',
			argument2   => "-e 401,403";
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
		"check_proc_status":
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
		"check_dnszone":
			conf_dir  => "generic",
			argument1 => '$ARG1$',
			argument2 => '$ARG2$',
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
		"ha_service":
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
			notification_interval        => "600",
			is_volatile                  => "0",
			check_period                 => "24x7",
			check_interval               => "10",
			retry_interval               => "10",
			max_check_attempts           => "3",
			notification_period          => "24x7",
			notification_options         => "w,u,c,r",
			contact_groups               => "kumina_email",
			register                     => "0";
		"critsms_service":
			conf_dir            => "generic",
			use                 => "ha_service",
			servicegroups       => "wh_services_critsms",
			notification_period => "workhours",
			register            => "0";
		"warnsms_service":
			conf_dir            => "generic",
			use                 => "ha_service",
			servicegroups       => "wh_services_warnsms",
			notification_period => "workhours",
			register            => "0";
		"mail_service":
			conf_dir              => "generic",
			use                   => "ha_service",
			servicegroups         => "mail_services",
			notification_period   => "workhours",
			notification_interval => "0",
			register              => "0";
		"passive_service":
			conf_dir               => "generic",
			use                    => "ha_service",
			servicegroups          => "mail_services",
			active_checks_enabled  => "0",
			passive_checks_enabled => "1",
			checkcommand           => "return-ok",
			notification_period    => "workhours",
			register               => "0";
	}

	gen_icinga::host {
		"ha_host":
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
			check_interval               => "10",
			notification_period          => "24x7",
			notification_interval        => "600",
			contact_groups               => "kumina_email",
			max_check_attempts           => "3",
			register                     => "0";
		"wh_host":
			conf_dir   => "generic",
			use        => "ha_host",
			hostgroups => "wh_hosts",
			register   => "0";
		"mail_host":
			conf_dir              => "generic",
			use                   => "ha_host",
			hostgroups            => "mail_hosts",
			notification_interval => "0",
			register              => "0";
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
	gen_icinga::contact { "${environment}":
		conf_dir                      => $environment,
		c_alias                       => "Generic ${environment} contact",
		host_notifications_enabled    => 0,
		service_notifications_enabled => 0,
		contact_data                  => false,
		notification_type             => "no-notify";
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
	kbp_icinga::service { "heartbeat_${fqdn}":
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
	kbp_icinga::service { "nfs_daemon_${fqdn}":
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
	kbp_icinga::service { "dhcp_daemon_${fqdn}":
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
	kbp_icinga::service { "cassandra_${fqdn}":
		service_description => "Cassandra status",
		check_command       => "check_cassandra",
		nrpe                => true;
	}
}

# Define: kbp_icinga::service
#
# Parameters:
#	ha
#		Undocumented
#	check_command
#		Undocumented
#	retry_interval
#		Undocumented
#	warnsms
#		Undocumented
#	host_name
#		Undocumented
#	contact_groups
#		Undocumented
#	argument1
#		Undocumented
#	nrpe
#		Undocumented
#	sms
#		Undocumented
#	argument2
#		Undocumented
#	conf_dir
#		Undocumented
#	argument3
#		Undocumented
#	passive
#		Undocumented
#	max_check_attempts
#		Undocumented
#	service_description
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::service($service_description, $check_command=false, $host_name=false, $contact_groups=false, $argument1=false, $argument2=false, $argument3=false, $max_check_attempts=false, $retry_interval=false, $nrpe=false, $conf_dir=false, $passive=false, $ha=false, $warnsms=true, $sms=true) {
	$use = $passive ? {
		true  => "passive_service",
		false => $ha ? {
			true  => "ha_service",
			false => $sms ? {
				false => "mail_service",
				true  => $warnsms ? {
					true  => "warnsms_service",
					false => "critsms_service",
				}
			}
		}
	}

	if $ha {
		$host = $hostname ? {
			false   => $fqdn,
			default => $hostname,
		}

		Gen_icinga::Host <| title == $host |> {
			hostgroups => "ha_hosts",
		}
	}

	gen_icinga::service { "${name}":
		conf_dir             => $conf_dir ? {
			false   => undef,
			default => $conf_dir,
		},
		use                  => $use,
		service_description  => $service_description,
		checkcommand         => $check_command ? {
			false   => undef,
			default => $check_command
		},
		hostname             => $host_name ? {
			false   => undef,
			default => $host_name,
		},
		contact_groups       => $contact_groups ? {
			false   => undef,
			default => $contact_groups,
		},
		argument1            => $argument1 ? {
			false   => undef,
			default => $argument1,
		},
		argument2            => $argument2 ? {
			false   => undef,
			default => $argument2,
		},
		argument3            => $argument3 ? {
			false   => undef,
			default => $argument3,
		},
		max_check_attempts   => $max_check_attempts ? {
			false   => undef,
			default => $max_check_attempts,
		},
		retry_interval       => $retry_interval ? {
			false   => undef,
			default => $retry_interval,
		},
		nrpe                 => $nrpe;
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
	kbp_icinga::service { "ssl_cert_${name}_${fqdn}":
		service_description => "SSL certificate in ${path}",
		check_command       => "check_sslcert",
		argument1           => $path,
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
define kbp_icinga::virtualhost($address, $conf_dir=$environment, $parents=false, $hostgroups=false, $contact_groups=false) {
	gen_icinga::configdir { "${conf_dir}/${name}":
		sub => $conf_dir;
	}

	gen_icinga::host { "${name}":
		conf_dir       => "${conf_dir}/${name}",
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
		};
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
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_icinga::haproxy($address, $ha=false, $url=false, $response=false) {
	$confdir = "${environment}/${name}"

	gen_icinga::configdir { $confdir:
		sub => $environment;
	}

	gen_icinga::host { "${name}":
		address => $address,
		parents => $loadbalancer::otherhost ? {
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
			argument1           => $url,
			argument2           => $response,
			ha                  => $ha;
		}
	} else {
		kbp_icinga::service { "virtual_host_${name}":
			conf_dir            => $confdir,
			service_description => "Virtual host ${name}",
			host_name           => $name,
			check_command       => "check_http_vhost",
			argument1           => $name,
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
	kbp_icinga::service { "java_heap_usage_${name}_${fqdn}":
		service_description => "Java heap usage ${name}",
		check_command       => "check_java_heap_usage",
		argument1           => $name,
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
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
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

		kbp_icinga::service { "vhost_${name}":
			conf_dir            => $confdir,
			service_description => "Vhost ${name}",
			host_name           => $name,
			check_command       => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			argument1           => $name;
		}
	} else {
		kbp_icinga::service { "vhost_${name}_${fqdn}":
			service_description => "Vhost ${name}",
			check_command       => $auth ? {
				false   => "check_http_vhost",
				default => "check_http_vhost_auth",
			},
			argument1           => $name;
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
	kbp_icinga::service { "ssl_site_${name}_${fqdn}":
		service_description => "SSL validity ${name}",
		check_command       => "check_ssl_cert",
		argument1           => "${name}";
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
	kbp_icinga::service { "${name}_${fqdn}":
		service_description => "Raid ${name} ${driver}",
		check_command       => "check_${driver}",
		nrpe                => true;
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
	kbp_icinga::service { "proc_status_${name}_${fqdn}":
		service_description => "Process status for ${name}",
		check_command       => "check_proc_status",
		argument1           => $name,
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
	kbp_icinga::service { "glassfish_${name}_${fqdn}":
		service_description => "Glassfish ${name} status",
		check_command       => "check_http_on_port_with_vhost_url_and_response",
		argument1           => $webport,
		argument2           => $statuspath ? {
			false   => "/${name}/status.jsp",
			default => "$statuspath/status.jsp",
		},
		argument3           => "RUNNING";
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
	kbp_icinga::service { "dnszone_${name}_${fqdn}":
		service_description => "DNS zone ${name} from ${master}",
		check_command       => "check_dnszone",
		argument1           => $name,
		argument2           => $master,
		nrpe                => true,
		sms                 => $sms;
	}
}
