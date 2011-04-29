class kbp_approx {
	include approx

	Kfile["/etc/approx/approx.conf"] {
		source => "kbp_approx/approx.conf",
	}

	ferm::new::rule { "APT proxy_v46":
		proto     => "tcp",
		dport     => "9999",
		action    => "ACCEPT";
	}
}
