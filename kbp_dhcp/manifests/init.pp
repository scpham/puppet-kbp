class kbp_dhcp::server {
	include dhcp::server

	ferm::new::rule { "DHCP requests":
		proto  => "udp",
		sport  => "bootpc",
		dport  => "bootps",
		action => "ACCEPT";
	}
}
