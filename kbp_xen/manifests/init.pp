class kbp_xen::dom0 inherits xen::dom0 {
	include "kbp_xen::dom0::$lsbdistcodename"
}

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

class kbp_xen::dom0::lenny {
}

class kbp_xen::domu inherits xen::domu {
}
