# Author: Kumina bv <support@kumina.nl>

# Class: kbp_postfix
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_postfix inherits postfix {
	include munin::client
	include gen_openssl::common

	munin::client::plugin { ["postfix_mailqueue", "postfix_mailstats", "postfix_mailvolume"]:
		ensure => present,
	}

	munin::client::plugin { ["exim_mailstats"]:
		ensure => absent,
	}

	# The Postfix init script copies /etc/ssl/certs stuff on (re)start, so restart Postfix
	# on changes!
	Service["postfix"] {
		require => File["/etc/ssl/certs"],
		subscribe => File["/etc/ssl/certs"],
	}
}

# Class: kbp_postfix::secondary
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_postfix::secondary {
	include kbp_postfix

	gen_ferm::rule { "SMTP connections":
		proto  => "tcp",
		dport  => 25,
		action => "ACCEPT";
	}
}

# Class: kbp_postfix::primary
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_postfix::primary {
	include kbp_postfix

	gen_ferm::rule { "SMTP connections":
		proto  => "tcp",
		dport  => "(25 465)",
		action => "ACCEPT";
	}
}
