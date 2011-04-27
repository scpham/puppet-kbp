class kbp_avahi::daemon {
	include avahi::daemon

	ferm::new::rule { "MDNS traffic,_v46":
		proto     => "udp",
		dport     => "5353",
		daddr     => "244.0.0.251",
		action    => "ACCEPT";
	}
}
