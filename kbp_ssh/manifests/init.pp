class kbp_ssh {
	ferm::rule { "SSH":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}
}
