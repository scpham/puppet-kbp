class kbp_bip {
	ferm::rule::new { "IRC/Bip connections":
		proto  => "tcp",
		dport  => "(6667 7000 7778)",
		action => "ACCEPT";
	}
}
