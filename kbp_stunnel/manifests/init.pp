define kbp_stunnel::site ($port=443) {
	ferm::rule { "Stunnel forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}
}
