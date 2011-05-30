class kbp_nsca::server($package="icinga") {
	include gen_nsca::server

	if $package == "icinga" {
		Kfile <| title == "/etc/nsca/nsca.cfg" |> {
			source => "kbp_nsca/nsca.cfg_icinga",
		}
	}

	Gen_ferm::Rule <<| tag == "nsca_${environment}" |>>
}

class kbp_nsca::client($package="munin") {
	include gen_nsca::client

	@@gen_ferm::rule { "NSCA connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "tcp",
		dport  => 5667,
		action => "ACCEPT",
		tag    => "nsca_${environment}";
	}
}
