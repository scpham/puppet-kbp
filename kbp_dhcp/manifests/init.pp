# Author: Kumina bv <support@kumina.nl>

# Class: kbp_dhcp::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_dhcp::server {
	include dhcp::server
	class { "kbp_monitoring::dhcp":; }

	gen_ferm::rule { "DHCP requests_v4":
		proto  => "udp",
		sport  => "bootpc",
		dport  => "bootps",
		action => "ACCEPT";
	}
}
