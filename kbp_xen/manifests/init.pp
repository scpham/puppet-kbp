# Author: Kumina bv <support@kumina.nl>

# Class: kbp_xen::dom0
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_xen::dom0 inherits xen::dom0 {
	include "kbp_xen::dom0::$lsbdistcodename"
}

# Class: kbp_xen::dom0::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_xen::dom0::etch {
	file {
		"/etc/xen-tools/xen-tools.conf":
			source => "puppet://puppet/kbp_xen/xen-tools/xen-tools.conf-etch",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["xen-tools"];
	}

	file {
		"/etc/xen-tools/role.d/kumina":
			source => "puppet://puppet/kbp_xen/xen-tools/role.d/kumina",
			owner => "root",
			group => "root",
			mode => 755,
			require => Package["xen-tools"];
	}
}

# Class: kbp_xen::dom0::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_xen::dom0::lenny {
}

# Class: kbp_xen::domu
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_xen::domu inherits xen::domu {
}
