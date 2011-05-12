class kbp_cassandra::server {
	ferm::new::rule { "Cassandra JMX connections":
		saddr  => "localhost",
		proto  => "tcp",
		dport  => 8080,
		action => "ACCEPT",
		tag    => "ferm_cassandra_rule_jmx";
	}
}
