# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apache
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache inherits apache {
	include kbp_munin::client::apache

	gen_ferm::rule {
		"HTTP connections":
			proto  => "tcp",
			dport  => "80",
			action => "ACCEPT";
		"HTTPS connections":
			proto  => "tcp",
			dport  => "443",
			action => "ACCEPT";
	}

	kfile {
		"/etc/apache2/mods-available/deflate.conf":
			source => "kbp_apache/mods-available/deflate.conf",
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
		"/etc/apache2/conf.d/security":
			source => "kbp_apache/conf.d/security",
			require => Package["apache2"],
			notify => Exec["reload-apache2"];
	}

	apache::module { "deflate":
		ensure => present,
	}

	@kpackage { "php5-gd":
		ensure  => latest,
		require => Package["apache2"],
		notify  => Exec["reload-apache2"];
	}

	kbp_monitoring::http { "http_${fqdn}":; }
}

# Class: kbp_apache::passenger
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache::passenger {
	include kbp_apache
	include kbp_apache::ssl

	kpackage { "libapache2-mod-passenger":
		ensure => latest;
	}

	apache::module { "passenger":
		require => Kpackage["libapache2-mod-passenger"],
	}
}

# Class: kbp_apache::ssl
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_apache::ssl {
	apache::module { "ssl":; }
}

# Define: kbp_apache::site
#
# Parameters:
#	priority
#		Undocumented
#	ensure
#		Undocumented
#	max_check_attempts
#		For overriding the default max_check_attempts of the service.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_apache::site($ensure="present", $priority="", auth=false, $max_check_attempts=false, $monitor_path=false, $monitor_probe=false) {
	$dontmonitor = ["default","default-ssl","localhost"]

	if $ensure == "present" and ! ($name in $dontmonitor) {
		kbp_monitoring::site { "${name}":
			max_check_attempts => $max_check_attempts,
			auth               => $auth;
		}

		kbp_smokeping::target { "${name}":
			probe => $monitor_probe ? {
				false   => $auth ? {
					false => undef,
					true  => "FPing",
				},
				default => $monitor_probe,
			},
			path  => $monitor_path ? {
				false   => undef,
				default => $monitor_path,
			};
		}
	}

	apache::site { "${name}":
		ensure   => $ensure,
		priority => $priority;
	}
}
