class kbp-bind inherits bind {
	class { "kbp_trending::bind9":
		method => "munin"
	}

	ferm::rule { "DNS connections":
		proto  => "(tcp udp)",
		dport  => 53,
		action => "ACCEPT";
	}

	@@ferm::rule { "Allow AXFR transfers from ${fqdn}":
		saddr  => $fqdn,
		proto  => "(tcp udp)",
		dport  => 53,
		action => "ACCEPT",
		tag    => "bind_${environment}";
	}
}
