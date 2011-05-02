class kbp_asterisk::server {
	include asterisk::server

	ferm::new::rule { "SIP connections":
		proto  => "udp",
		dport  => "(sip 15000:15100)",
		action => "ACCEPT";
	}
}
