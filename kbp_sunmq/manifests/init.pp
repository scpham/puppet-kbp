class kbp_sunmq($withJMS=false) {
	gen_ferm::rule { "SunMQ ports":
		proto  => "tcp",
		dport  => "(7676 10236)",
		action => "ACCEPT",
		tag    => "sunmq";
	}
	
	if $withJMS {
		gen_ferm::rule { "SunMQ JMS port":
			proto  => "tcp",
			dport  => "10234",
			action => "ACCEPT",
			tag    => "sunmq";
		}
	}
}
