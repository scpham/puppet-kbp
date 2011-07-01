# Author: Kumina bv <support@kumina.nl>

# Class: kbp_arpwatch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_arpwatch {
	include arpwatch

	Kfile <| title == "/etc/default/arpwatch" |> {
		source => "kbp_arpwatch/arpwatch",
	}

	gen_icinga::service { "arpwatch_${fqdn}":
		service_description => "Arpwatch daemon",
		checkcommand        => "check_arpwatch",
		nrpe                => true;
	}
}
