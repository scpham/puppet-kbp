# Author: Kumina bv <support@kumina.nl>

# Class: kbp_varnish
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_varnish inherits varnish {
	include munin::client

	munin::client::plugin { "varnish_ratio":
		script_path => "/usr/local/share/munin/plugins",
		script => "varnish_",
	}
}
