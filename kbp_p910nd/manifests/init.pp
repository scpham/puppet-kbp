class kbp_p910nd::server {
	include p910nd::server

	ferm::new::rule { "Printing connections_46":
		proto     => "tcp",
		dport     => "9100",
		action    => "ACCEPT";
	}
}
