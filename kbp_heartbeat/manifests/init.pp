class kbp_heartbeat($otherhost) {
	Ferm::New::Rule <<| tag == "ferm_heartbeat_rule_${otherhost}" |>>

	@@ferm::new::rule { "Heartbeat connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 694,
		action => "ACCEPT",
		tag    => "ferm_heartbeat_rule_${fqdn}";
	}
}
