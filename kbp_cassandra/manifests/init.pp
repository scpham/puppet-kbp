class kbp_cassandra::client($customtag="cassandra_${environment}") {
	@@ferm::rule { "Cassandra connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 8080,
		action => "ACCEPT",
		tag    => $customtag;
	}
}

class kbp_cassandra::server {
	Ferm::Rule <<| tag == "cassandra_${environment}" |>>
	Ferm::Rule <<| tag == "cassandra_monitoring" |>>
}
