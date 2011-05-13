class kbp_ssh {
	ferm::rule { "SSH_v46":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}
}
