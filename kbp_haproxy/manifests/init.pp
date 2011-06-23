define kbp_haproxy::site ($listenaddress, $port=80, $monitoring=true, $ha=false) {
	gen_ferm::rule { "HAProxy forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}

	if $monitoring {
		kbp_monitoring::haproxy { "${name}":
			address => $listenaddress,
			ha      => $ha;
		}
	}
}
