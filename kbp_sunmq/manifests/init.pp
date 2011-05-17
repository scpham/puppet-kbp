class kbp_sunmq {
	ferm::rule {
		"SunMQ ports":
			proto  => "tcp",
			dport  => "(7676 10236)",
			action => "ACCEPT",
			tag    => "sunmq";
		"JMS port":
			proto  => "tcp",
			dport  => "10234",
			action => "ACCEPT",
			tag    => "sunmq";
	}
}
