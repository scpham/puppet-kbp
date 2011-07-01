# Author: Kumina bv <support@kumina.nl>

# Class: kbp_php::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::common inherits php::common {
	include munin::client

	file { "/etc/php$phpversion/conf.d/security.ini":
		owner => "root",
		group => "root",
		mode => 644,
		source => "puppet://puppet/php/shared/conf.d/security.ini",
	}

	package { "php-apc":
		ensure => installed,
	}

	munin::client::plugin { "apc":
		script_path => "/usr/local/share/munin/plugins/apc_",
		require => Package["php-apc"],
	}
}

# Class: kbp_php::php5::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php5::common inherits php::php5::common {
	include kbp_php::common
}

# Class: kbp_php::php5::modphp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php5::modphp inherits php::php5::modphp {
	include kbp_php::php5::common
}

# Class: kbp_php::php5::cgi
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php5::cgi inherits php::php5::cgi {
	include kbp_php::php5::common
}

# Class: kbp_php::php5::cli
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php5::cli inherits php::php5::cli {
	include kbp_php::php5::common
}

# Class: kbp_php::php4::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php4::common inherits php::php4::common {
	include kbp_php::common
}

# Class: kbp_php::php4::modphp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php4::modphp inherits php::php4::modphp {
	include kbp_php::php4::common
}

# Class: kbp_php::php4::cgi
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php4::cgi inherits php::php4::cgi {
	include kbp_php::php4::common
}

# Class: kbp_php::php4::cli
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_php::php4::cli inherits php::php4::cli {
	include kbp_php::php4::common
}
