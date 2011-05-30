define kbp_stunnel::site ($port=443) {
	gen_ferm::rule { "Stunnel forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}
}
