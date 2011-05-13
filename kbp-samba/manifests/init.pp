class kbp-samba::server inherits samba::server {
	ferm::rule { "Samba traffic (netbios-ns)_v46":
		proto     => "udp",
		dport     => "137",
		action    => "ACCEPT";
	}

	ferm::rule { "Samba traffic (netbios-dgm)_v46":
		proto     => "udp",
		dport     => "138",
		action    => "ACCEPT";
	}

	ferm::rule { "Samba traffic (netbios-ssn)_v46":
		proto     => "tcp",
		dport     => "139",
		action    => "ACCEPT";
	}

	ferm::rule { "Samba traffic (microsoft-ds)_v46":
		proto     => "tcp",
		dport     => "445",
		action    => "ACCEPT";
	}
}
