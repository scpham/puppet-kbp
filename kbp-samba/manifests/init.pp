class kbp-samba::server inherits samba::server {
	ferm::new::rule { "Samba traffic (netbios-ns)":
		proto     => "udp",
		dport     => "137",
		action    => "ACCEPT";
	}

	ferm::new::rule { "Samba traffic (netbios-dgm)":
		proto     => "udp",
		dport     => "138",
		action    => "ACCEPT";
	}

	ferm::new::rule { "Samba traffic (netbios-ssn)":
		proto     => "tcp",
		dport     => "139",
		action    => "ACCEPT";
	}

	ferm::new::rule { "Samba traffic (microsoft-ds)":
		proto     => "tcp",
		dport     => "445",
		action    => "ACCEPT";
	}
}
