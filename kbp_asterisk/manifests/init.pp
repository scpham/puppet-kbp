class kbp_asterisk::server {
	include asterisk::server

	ferm::rule { "SIP connections":
		proto  => "udp",
		dport  => "(sip 15000:15100)",
		action => "ACCEPT";
	}

	@@ferm::rule { "Asterisk CDR logging from ${fqdn}_v4":
		saddr  => "81.30.39.28",
		proto  => "tcp",
		dport  => 3306,
		action => "ACCEPT",
		tag    => "mysql_asterisk";
	}
}
