# Author: Kumina bv <support@kumina.nl>

# Class: kbp_approx
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_approx {
	include approx

	Kfile <| title == "/etc/approx/approx.conf" |> {
		source => "kbp_approx/approx.conf",
	}

	gen_ferm::rule { "APT proxy":
		proto     => "tcp",
		dport     => "9999",
		action    => "ACCEPT";
	}
}
