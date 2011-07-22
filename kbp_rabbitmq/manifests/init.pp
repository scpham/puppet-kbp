# Author: Kumina bv <support@kumina.nl>

# Class: kbp_rabbitmq
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_rabbitmq($version) {
	class { "gen_rabbitmq":
		version => $version;
	}
}
