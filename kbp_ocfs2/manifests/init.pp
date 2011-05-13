class kbp_ocfs2($otherhost) {
	Ferm::Rule <<| tag == "ferm_ocfs2_rule_${otherhost}" |>>

	@@ferm::rule { "OCFS2 connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 7777,
		action => "ACCEPT",
		tag    => "ferm_ocfs2_rule_${fqdn}";
	}
}
