class kbp_cassandra::server {
	ferm::new::rule { "Cassandra JMX connections":
		saddr  => "localhost",
		proto  => "tcp",
		dport  => 8080,
		action => "ACCEPT";
	}
}
