class kbp_cassandra::client {
	@@ferm::rule { "Cassandra connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 8080,
		action => "ACCEPT",
		tag    => "cassandra_${environment}";
	}
}

class kbp_cassandra::server {
	Ferm::Rule <<| tag == "ferm_cassandra_${environment}" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_${environment}_stage" |>>
	Ferm::Rule <<| tag == "ferm_cassandra_monitoring" |>>
}
