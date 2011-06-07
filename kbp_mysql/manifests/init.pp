class kbp_mysql::server($otherhost=false) {
	include mysql::server
	include kbp_trending::mysql
	class { "kbp_mysql::monitoring::icinga::server":
		otherhost => $otherhost,
	}

	Gen_ferm::Rule <<| tag == "mysql_${environment}" |>>
	Gen_ferm::Rule <<| tag == "mysql_monitoring" |>>
}

class kbp_mysql::slave($otherhost, $customtag="mysql_${environment}") {
	class { "kbp_mysql::server":
		otherhost => $otherhost,
	}

	Gen_ferm::Rule <<| tag == "mysql_${fqdn}" |>>
	Mysql::Server::Grant <<| tag == "mysql_${fqdn}" |>>

	@@mysql::server::grant {
		"repl":
			user        => "repl",
			password    => "etohsh8xahNu",
			hostname    => $fqdn,
			db          => "*",
			permissions => "replication slave",
			tag         => $otherhost;
		"nagios_slavecheck":
			user        => "nagios",
			db          => "*",
			permissions => "super, replication client",
			tag         => $otherhost;
	}

	@@gen_ferm::rule { "MySQL slaving from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => $otherhost;
	}

	gen_icinga::service { "mysql_slaving_${fqdn}":
		service_description => "MySQL slaving",
		checkcommand        => "check_mysql_slave",
		nrpe                => true;
	}
}

class kbp_mysql::client($customtag="mysql_${environment}") {
	@@gen_ferm::rule { "MySQL connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => $customtag;
	}
}

class kbp_mysql::monitoring::icinga::server($otherhost=false) {
	gen_icinga::service { "mysql_${fqdn}":
		service_description => "MySQL service",
		checkcommand        => "check_mysql",
		nrpe                => true;
	}

	if $otherhost {
		gen_icinga::servicedependency { "mysql_dependency_${fqdn}":
			dependent_service_description => "MySQL service",
			host_name                     => $otherhost,
			service_description           => "MySQL service";
		}
	}

	mysql::user { "monitoring":
		user => "nagios";
	}
}
