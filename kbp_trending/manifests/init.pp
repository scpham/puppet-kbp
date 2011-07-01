# Author: Kumina bv <support@kumina.nl>

# Class: kbp_trending
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending {
}

# Class: kbp_trending::puppetmaster
#
# Parameters:
#	method
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending::puppetmaster ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::puppetmaster }
		default: { fail("No trending for ${method}.") }
	}
}

# Class: kbp_trending::mysql
#
# Parameters:
#	method
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending::mysql ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::mysql }
		default: { fail("No trending for ${method}.") }
	}
}

# Class: kbp_trending::nfs
#
# Parameters:
#	method
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending::nfs ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::nfs }
		default: { fail("No trending for ${method}.") }
	}
}

# Class: kbp_trending::nfsd
#
# Parameters:
#	method
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending::nfsd ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::nfsd }
		default: { fail("No trending for ${method}.") }
	}
}

# Class: kbp_trending::bind9
#
# Parameters:
#	method
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_trending::bind9 ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::bind9 }
		default: { fail("No trending for ${method}.") }
	}
}
