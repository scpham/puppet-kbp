class kbp_approx {
	include approx

	ferm::new::rule { "APT proxy":
		proto     => "tcp",
		dport     => "9999",
		action    => "ACCEPT";
	}
}
