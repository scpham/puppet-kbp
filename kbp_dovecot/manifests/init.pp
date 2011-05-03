class kbp_dovecot::imap {
	include dovecot::imap

	ferm::new::rule { "IMAP connections":
		proto  => "tcp",
		dport  => "(143 993)",
		action => "ACCEPT";
	}
}
