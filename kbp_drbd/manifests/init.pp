class kbp_drbd($otherhost) {
	include kbp_drbd::monitoring::icinga

	Ferm::Rule <<| tag == "drbd_${otherhost}" |>>

	@@ferm::rule { "DRBD connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 7789,
		action => "ACCEPT",
		tag    => "drbd_${fqdn}";
	}
}

class kbp_drbd::monitoring::icinga {
	kbp_icinga::service { "check_drbd_${fqdn}":
		service_description => "DRBD",
		checkcommand        => "check_drbd",
		nrpe                => true;
	}
}
