class kbp_bip {
	gen_ferm::rule { "IRC/Bip connections":
		proto  => "tcp",
		dport  => "(6667 7000 7778)",
		action => "ACCEPT";
	}
}
