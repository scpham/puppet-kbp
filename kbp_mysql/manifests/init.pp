class kbp_mysql::server($otherhost=false) {
	include mysql::server
	include kbp_trending::mysql
	class { "kbp_mysql::monitoring::icinga::server":
		otherhost => $otherhost,
	}

	Ferm::Rule <<| tag == "mysql_${environment}" |>>
	Ferm::Rule <<| tag == "mysql_monitoring" |>>
}

class kbp_mysql::client($customtag="mysql_${environment}") {
	@@ferm::rule { "MySQL connections from ${fqdn}":
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
