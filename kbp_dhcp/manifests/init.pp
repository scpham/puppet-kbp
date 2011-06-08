class kbp_dhcp::server {
	include dhcp::server
	class { "kbp_monitoring::dhcp":; }

	gen_ferm::rule { "DHCP requests":
		proto  => "udp",
		sport  => "bootpc",
		dport  => "bootps",
		action => "ACCEPT";
	}
}
