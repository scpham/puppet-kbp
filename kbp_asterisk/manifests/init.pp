class kbp_asterisk::server {
	include asterisk::server

	ferm::new::rule { "SIP connections":
		proto  => "udp",
		dport  => "(sip 15000:15100)",
		action => "ACCEPT";
	}

	@@ferm::new::rule { "Asterisk CDR logging from ${fqdn}_v4":
		saddr  => "81.30.39.28",
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => "ferm_mysql_rule_asterisk";
	}
}
