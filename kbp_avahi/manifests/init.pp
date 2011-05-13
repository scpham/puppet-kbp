class kbp_avahi::daemon {
	include avahi::daemon

	ferm::rule {
		"MDNS traffic_v4":
			proto     => "udp",
			dport     => "5353",
			daddr     => "244.0.0.251",
			action    => "ACCEPT";
		"MDNS traffic_v6":
			proto     => "udp",
			dport     => "5353",
			daddr     => "ff02::fb",
			action    => "ACCEPT";
	}
}
