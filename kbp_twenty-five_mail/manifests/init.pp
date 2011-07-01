# Author: Kumina bv <support@kumina.nl>

# Class: kbp_twenty-five_mail::monitoring::icinga
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_twenty-five_mail::monitoring::icinga {
	gen_icinga::service { "smtp_gateway_${fqdn}":
		service_description => "SMTP gateway",
		checkcommand        => "check_local_smtp",
		nrpe                => true;
	}
}
