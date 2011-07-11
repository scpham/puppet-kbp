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
	kbp_icinga::service { "smtp_gateway":
		service_description => "SMTP gateway",
		check_command       => "check_local_smtp",
		nrpe                => true;
	}
}
