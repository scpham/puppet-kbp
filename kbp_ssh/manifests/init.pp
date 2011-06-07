class kbp_ssh {
	gen_ferm::rule { "SSH":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}
}
