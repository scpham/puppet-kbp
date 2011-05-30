class kbp_cassandra::client($customtag="cassandra_${environment}") {
	@@gen_ferm::rule { "Cassandra connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 9160,
		action => "ACCEPT",
		tag    => $customtag;
	}
}

class kbp_cassandra::server($customtag="cassandra_${environment}") {
	@@gen_ferm::rule { "Internal Cassandra connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 7000,
		action => "ACCEPT",
		tag    => $customtag;
	}

	Gen_ferm::Rule <<| tag == $customtag |>>
	Gen_ferm::Rule <<| tag == "cassandra_monitoring" |>>
}
