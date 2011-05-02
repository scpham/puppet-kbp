class kbp-bind inherits bind {
	include munin::client

	munin::client::plugin { "bind9_rndc":
		ensure => present,
	}

	munin::client::plugin::config { "bind9_rndc":
		content => "env.querystats /var/cache/bind/named.stats\nuser bind",
	}

	ferm::new::rule { "DNS connections":
		proto  => "(tcp udp)",
		dport  => 53,
		action => "ACCEPT";
	}

	@@ferm::new::rule { "Allow AXFR transfers from ${fqdn}_v46":
		saddr  => $fqdn,
		proto  => "(tcp udp)",
		dport  => 53,
		action => "ACCEPT",
		tag    => "ferm_bind_rule_${environment}";
	}
}
