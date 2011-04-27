class kbp-samba inherits samba::server {
	package { "smbldap-tools":
		ensure => installed,
	}

	file {
		"/etc/smbldap-tools/smbldap_bind.conf":
			content => template("kbp-samba/smbldap-tools/smbldap_bind.conf"),
			owner => "root",
			group => "root",
			mode => 640,
			require => Package["smbldap-tools"];
		"/etc/smbldap-tools/smbldap.conf":
			content => template("kbp-samba/smbldap-tools/smbldap.conf"),
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["smbldap-tools"];
	}

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
