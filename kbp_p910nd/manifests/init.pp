class kbp_p910nd::server {
	include p910nd::server

	ferm::rule { "Printing connections_v46":
		proto     => "tcp",
		dport     => "9100",
		action    => "ACCEPT";
	}
}
