class kbp_dovecot {
	include dovecot

	ferm::new::rule { "IMAP connections":
		proto  => "tcp",
		dport  => "(143 993)",
		action => "ACCEPT";
	}
}
