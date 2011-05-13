class kbp_drbd($otherhost) {
	include kbp_drbd::monitoring::icinga

	Ferm::Rule <<| tag == "ferm_drbd_rule_${otherhost}" |>>

	@@ferm::rule { "DRBD connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 7789,
		action => "ACCEPT",
		tag    => "ferm_drbd_rule_${fqdn}";
	}
}

class kbp_drbd::monitoring::icinga {
	kbp_icinga::service { "check_drbd_${fqdn}":
		service_description => "DRBD",
		checkcommand        => "check_drbd",
		nrpe                => true;
	}
}
