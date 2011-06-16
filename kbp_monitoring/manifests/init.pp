class kbp_monitoring::client::sslcert {
	include kbp_sudo

	gen_sudo::rule { "check_sslcert sudo rules":
		entity => "nagios",
		as_user => "root",
		password_required => false,
		command =>"/usr/lib/nagios/plugins/check_sslcert";
	}
}

class kbp_monitoring::server($package="icinga") {
	case $package {
		"icinga": { include kbp_icinga::server }
		"nagios": { include kbp_nagios::server }
	}

	@@gen_ferm::rule {
		"NRPE monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 5666,
			action => "ACCEPT",
			tag    => "general";
		"MySQL monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 3306,
			action => "ACCEPT",
			tag    => "mysql_monitoring";
		"Sphinxsearch monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 3312,
			action => "ACCEPT",
			tag    => "sphinxsearch_monitoring";
		"Cassandra monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => "(7000 8080 9160)",
			action => "ACCEPT",
			tag    => "cassandra_monitoring";
		"Glassfish monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "tcp",
			dport  => 80,
			action => "ACCEPT",
			tag    => "glassfish_monitoring";
		"NFS monitoring from ${fqdn}":
			saddr  => $fqdn,
			proto  => "(tcp udp)",
			dport  => "(111 2049)",
			action => "ACCEPT",
			tag    => "nfs_monitoring";
	}
}

class kbp_monitoring::heartbeat($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::heartbeat
		}
	}
}

class kbp_monitoring::nfs($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::nfs
		}
	}
}

class kbp_monitoring::dhcp($package="icinga") {
	case $package {
		"icinga": {
			include kbp_icinga::dhcp
		}
	}
}

define kbp_monitoring::sslcert($path, $package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::sslcert { "${name}":
				path => $path;
			}
		}
	}
}

define kbp_monitoring::haproxy($address, $package="icinga") {
	case $package {
		"icinga": {
			kbp_icinga::haproxy { "${name}":
				address => $address;
			}
		}
	}
}

define kbp_monitoring::java($package="icinga", contact_groups=false, servicegroups=false) {
	case $package {
		"icinga": {
			kbp_icinga::java { "${name}":
				contact_groups => $contact_groups,
				servicegroups  => $servicegroups;
			}
		}
	}
}

define kbp_monitoring::site($package="icinga", $address=false, $conf_dir=$false, $parents=$false, $auth=false) {
	case $package {
		"icinga": {
			kbp_icinga::site { "${name}":
				address  => $address ? {
					false   => undef,
					default => $adddress,
				},
				conf_dir => $conf_dir ? {
					false   => undef,
					default => $conf_dir,
				},
				parents  => $parents ? {
					false   => undef,
					default => $parents,
				},
				auth     => $auth;
			}
		}
	}
}

define kbp_monitoring::raidcontroller($package="icinga", $driver) {
	case $package {
		"icinga": {
			kbp_icinga::raidcontroller { "${name}":
				driver => $driver;
			}
		}
	}
}

define kbp_monitoring::http($package="icinga", $customfqdn=false) {
	case $package {
		"icinga": {
			kbp_icinga::http { "${name}":
				customfqdn => $customfqdn ? {
					false   => undef,
					default => $customfqdn,
				};
			}
		}
	}
}
