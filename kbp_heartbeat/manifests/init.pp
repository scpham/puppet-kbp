class kbp_heartbeat($otherhost) {
	include kbp_monitoring::heartbeat

	ferm::rule { "Heartbeat connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "udp",
		dport  => 694,
		action => "ACCEPT";
	}
}
