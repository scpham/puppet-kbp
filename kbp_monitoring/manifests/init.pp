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
			kbp_icinga::heartbeat { "${name}":; }
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
