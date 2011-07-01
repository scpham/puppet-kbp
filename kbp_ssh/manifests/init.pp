# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ssh
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_ssh {
	gen_ferm::rule { "SSH":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}
}
