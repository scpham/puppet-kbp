# Author: Kumina bv <support@kumina.nl>

# Class: kbp_git
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_git {
	include gen_git
}

# Class: kbp_git::gitg
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_git::gitg {
	include gen_git::gitg
}

# Class: kbp_git::listchanges
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_git::listchanges {
	include gen_git::listchanges
}
