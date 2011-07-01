# Author: Kumina bv <support@kumina.nl>

# Class: kbp_xvfb
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_xvfb {
	include gen_xvfb

	kfile { "/usr/local/bin/xvfb-run-patched":
		source => "kbp_xvfb/xvfb-run-patched.sh",
		mode => 755,
		require => Package["xvfb"];
	}
}
