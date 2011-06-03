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

	@package { "php5-gd":
		ensure  => latest,
		require => Package["apache2"],
		notify  => Exec["reload-apache2"];
	}
}

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

class kbp_apache::ssl {
	apache::module { "ssl":; }
}

define kbp_apache::site($ensure="present", $priority="", auth=false) {
	if $ensure == "present" {
		kbp_monitoring::site { "${name}":
			auth => $auth;
		}
	}

	apache::site { "${name}":
		ensure   => $ensure,
		priority => $priority;
	}
}
