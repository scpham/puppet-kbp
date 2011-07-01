# Author: Kumina bv <support@kumina.nl>

# Class: kbp_nsca::server
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_nsca::server($package="icinga") {
	include gen_nsca::server

	if $package == "icinga" {
		Kfile <| title == "/etc/nsca/nsca.cfg" |> {
			source => "kbp_nsca/nsca.cfg_icinga",
		}
	}

	Gen_ferm::Rule <<| tag == "nsca_${environment}" |>>
}

# Class: kbp_nsca::client
#
# Parameters:
#	package
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
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
