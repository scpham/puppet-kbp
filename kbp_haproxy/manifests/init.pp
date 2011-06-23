define kbp_haproxy::site ($listenaddress, $port=80, $monitoring=true, $ha=false, $url=false, $response=false) {
	gen_ferm::rule { "HAProxy forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}

	if $monitoring {
		kbp_monitoring::haproxy { "${name}":
			address  => $listenaddress,
			ha       => $ha,
			url      => $url ? {
				false   => undef,
				default => $url,
			},
			response => $response ? {
				false   => undef,
				default => $response,
			};
		}
	}
}
