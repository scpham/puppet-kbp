class kbp_drbd($otherhost) {
	include kbp_drbd::monitoring::icinga

	gen_ferm::rule { "DRBD connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "tcp",
		dport  => 7789,
		action => "ACCEPT";
	}
}

class kbp_drbd::monitoring::icinga {
	gen_icinga::service { "check_drbd_${fqdn}":
		service_description => "DRBD",
		checkcommand        => "check_drbd",
		nrpe                => true;
	}
}
