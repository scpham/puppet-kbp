class kbp_heartbeat($otherhost) {
	Ferm::Rule <<| tag == "heartbeat_${otherhost}" |>>

	@@ferm::rule { "Heartbeat connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "udp",
		dport  => 694,
		action => "ACCEPT",
		tag    => "heartbeat_${fqdn}";
	}
}
