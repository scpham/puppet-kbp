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

	kbp_icinga::service { "arpwatch_${fqdn}":
		service_description => "Arpwatch daemon",
		check_command       => "check_arpwatch",
		nrpe                => true;
	}
}
