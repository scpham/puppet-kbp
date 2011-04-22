class kbp_ssh {
	@@ferm::new::rule { "SSH_v46":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}
}
