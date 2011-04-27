class kbp_approx {
	include approx

	ferm::new::rule { "APT proxy_v46":
		proto     => "tcp",
		dport     => "9999",
		action    => "ACCEPT";
	}
}
