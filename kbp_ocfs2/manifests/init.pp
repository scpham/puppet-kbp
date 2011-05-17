class kbp_ocfs2($otherhost) {
	ferm::rule { "OCFS2 connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "tcp",
		dport  => 7777,
		action => "ACCEPT";
	}
}
