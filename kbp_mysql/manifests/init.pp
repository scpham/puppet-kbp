class kbp_mysql::server {
	include mysql::server
	include kbp_mysql::monitoring::icinga::server
	class { "kbp_trending::mysql":; }

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

class kbp_mysql::monitoring::icinga::server
{
	kbp_icinga::service { "mysql_${fqdn}":
		service_description => "MySQL service",
		checkcommand        => "check_mysql";
	}
}
