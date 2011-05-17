class kbp_heartbeat($otherhost) {
	ferm::rule { "Heartbeat connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "udp",
		dport  => 694,
		action => "ACCEPT";
	}
}
