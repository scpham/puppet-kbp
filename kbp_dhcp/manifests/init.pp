class kbp_dhcp::server {
	include dhcp::server

	gen_ferm::rule { "DHCP requests":
		proto  => "udp",
		sport  => "bootpc",
		dport  => "bootps",
		action => "ACCEPT";
	}
}
