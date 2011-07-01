# Author: Kumina bv <support@kumina.nl>

# Define: kbp_stunnel::site
#
# Parameters:
#	port
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_stunnel::site ($port=443) {
	gen_ferm::rule { "Stunnel forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}
}
