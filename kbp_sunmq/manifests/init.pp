class kbp_sunmq {
	ferm::new::rule { "SunMQ ports":
		proto  => "tcp",
		dport  => "(7676 10236)",
		action => "ACCEPT";
	}
}
