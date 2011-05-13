class kbp_ocfs2($otherhost) {
	Ferm::Rule <<| tag == "ocfs2_${otherhost}" |>>

	@@ferm::rule { "OCFS2 connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 7777,
		action => "ACCEPT",
		tag    => "ocfs2_${fqdn}";
	}
}
