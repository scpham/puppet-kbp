# Author: Kumina bv <support@kumina.nl>

# Class: kbp_drbd
#
# Parameters:
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_drbd($otherhost) {
	include kbp_drbd::monitoring::icinga

	gen_ferm::rule { "DRBD connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "tcp",
		dport  => 7789,
		action => "ACCEPT";
	}
}

# Class: kbp_drbd::monitoring::icinga
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_drbd::monitoring::icinga {
	kbp_icinga::service { "check_drbd":
		service_description => "DRBD",
		check_command       => "check_drbd",
		nrpe                => true;
	}
}
